# Common CMake functions

# Setup a new CPU architecture.
# * name		Name of the architecture (and current subdir)
function(add_architecture name)
	add_library(menix_arch_${name} STATIC ${ARGN})

	# Set linker script and common search paths.
	set(CMAKE_EXE_LINKER_FLAGS "-T ${CMAKE_CURRENT_SOURCE_DIR}/${name}.ld -L ${MENIX_SRC} -L ${MENIX_SRC}/toolchain/linker" CACHE INTERNAL "")
	require_option(arch_${name})
	require_option(${MENIX_BITS}_bit)
endfunction(add_architecture)

# Appends this directory to the Linker Script include search path.
function(add_linker_dir)
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -L ${CMAKE_CURRENT_SOURCE_DIR}" CACHE INTERNAL "")
endfunction(add_linker_dir)

# Setup a new module for the build process.
# * name		Name of the module (e.g. example)
# * author		Author of the module (e.g. "John Smith")
# * desc		Short description of the module
# * license		License of the module (e.g. "MIT") or "MAIN", if the project's main license.
# * modular		Can the module be loaded dynamically or not? (TRUE/FALSE)
# * default		Default configuration value (ON/MOD/OFF)
function(add_module name author desc license modular default)
	# Generate a config entry if there is none already. If there is, include its values.
	if(NOT DEFINED MENIX_HAS_CONFIG)
		file(APPEND ${MENIX_CONFIG_SRC} "config_option(${MENIX_CURRENT_MOD} ${default})\n")
	else()
		include(${MENIX_CONFIG_SRC})
	endif()

	# If the option is not in cache yet, use the default value.
	if(NOT DEFINED CACHE{${MENIX_CURRENT_MOD}})
		set(${MENIX_CURRENT_MOD} ${default} CACHE INTERNAL "")
	endif()

	# Check if module is modular and also not built as modular by default.
	if(${modular} STREQUAL FALSE AND ${default} STREQUAL MOD)
		message(FATAL_ERROR "A non-modular module can't have MOD as default!")
	endif()

	if(${modular} STREQUAL FALSE AND ${${MENIX_CURRENT_MOD}} STREQUAL MOD)
		message(FATAL_ERROR "A non-modular module can't be built as a module!")
	endif()

	if(${${MENIX_CURRENT_MOD}} STREQUAL ON OR ${${MENIX_CURRENT_MOD}} STREQUAL MOD)
		# Determine if the module should be linked statically.
		if(${${MENIX_CURRENT_MOD}} STREQUAL ON)
			# Build as an object library to retain e.g. the module struct since
			# it's technically not referenced anywhere. The linker will discard
			# them otherwise.
			add_library(${MENIX_CURRENT_MOD} OBJECT ${ARGN})

			target_link_libraries(${MENIX_PARENT_CAT} INTERFACE $<TARGET_OBJECTS:${MENIX_CURRENT_MOD}>)

			# If built-in, define MODULE_TYPE to let the module know.
			target_compile_definitions(${MENIX_CURRENT_MOD} PRIVATE MODULE_TYPE='B')

			# Define a macro to check for presence of this module.
			file(APPEND ${MENIX_CONFIG} "#define CONFIG_${MENIX_CURRENT_MOD} 1\n")
		else()
			add_executable(${MENIX_CURRENT_MOD} ${ARGN})

			# If compiling as a module, define MODULE_TYPE to let the module know.
			target_compile_definitions(${MENIX_CURRENT_MOD} PRIVATE MODULE_TYPE='M')

			# Module should be completely relocatable.
			target_link_options(${MENIX_CURRENT_MOD} PRIVATE -r)
		endif()

		target_compile_definitions(${MENIX_CURRENT_MOD} PRIVATE
			MODULE_NAME="${name}"
			MODULE_AUTHOR="${author}"
			MODULE_DESCRIPTION="${desc}"
		)

		# Evaluate module license
		if(${license} STREQUAL "MAIN")
			target_compile_definitions(${MENIX_CURRENT_MOD} PRIVATE MODULE_LICENSE="${MENIX_LICENSE}")
			require_option(license_${MENIX_LICENSE})
		else()
			target_compile_definitions(${MENIX_CURRENT_MOD} PRIVATE MODULE_LICENSE="${license}")
			require_option(license_${license})
		endif()

		# Add local include directory to search path.
		target_include_directories(${MENIX_CURRENT_MOD} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
	endif()
endfunction(add_module)

# Configuration function for including a module in the build process.
function(build_module name)
	set(MENIX_CURRENT_MOD ${name} CACHE INTERNAL "")

	if(NOT "${${MENIX_CURRENT_MOD}}" STREQUAL OFF)
		add_subdirectory(${name})
	endif()
endfunction(build_module)

function(define_option optname)
	if(NOT ${${optname}} STREQUAL OFF)
		if(${${optname}} STREQUAL ON)
			file(APPEND ${MENIX_CONFIG} "#define CONFIG_${optname} 1\n")
		else()
			file(APPEND ${MENIX_CONFIG} "#define CONFIG_${optname} ${${optname}}\n")
		endif()
	endif()
endfunction(define_option)

# Configuration function for adding options to a module.
function(add_option optname default)
	if(NOT DEFINED CACHE{${optname}})
		set(${optname} ${default} CACHE INTERNAL "")
	endif()

	if(NOT DEFINED MENIX_HAS_CONFIG)
		file(APPEND ${MENIX_CONFIG_SRC} "config_option(${optname} ${default})\n")
	endif()

	define_option(${optname})
endfunction(add_option)

# Overwrite default values for including modules.
# Values: ON, OFF, String, Number
function(config_option name status)
	# Set a global variable to be evaluated before any other.
	set(${name} ${status} CACHE INTERNAL "")
endfunction(config_option)

# Automatically select a required option.
function(require_option optname)
	# If the option is not explicitly turned off, just define it.
	if(NOT DEFINED CACHE{${optname}})
		set(${optname} ON CACHE INTERNAL "")

	# If it's explicitly turned off, we can't compile.
	elseif(NOT ${optname} STREQUAL ON)
		message(FATAL_ERROR "\"${MENIX_CURRENT_MOD}\" requires \"${optname}\" to build, but this was explicitly turned off in the config!\n"
			"You might want to rebuild the cache.")
	endif()

	define_option(${optname})
endfunction(require_option)

# This module can not be enabled while another option is active.
function(conflicts_option optname)
	get_cmake_property(all_variables VARIABLES)

	foreach(var ${all_variables})
		string(REGEX MATCH "${optname}" match ${var})

		if(match)
			if(DEFINED CACHE{${var}})
				# Check if option is enabled and not the named the same as our current option.
				if(${var} STREQUAL ON AND ${MENIX_CURRENT_MOD} STREQUAL ON AND NOT var STREQUAL MENIX_CURRENT_MOD)
					message(FATAL_ERROR "Module \"${MENIX_CURRENT_MOD}\" conflicts with \"${var}\", you can't have both enabled at once!")
				endif()
			endif()
		endif()
	endforeach()
endfunction(conflicts_option)
