# Main kernel sources

add_executable(menix
	main.c
	module.c
	syscall_table.c
)

# Global include directories.
include_directories(${MENIX_SRC}/include/)
include_directories(${MENIX_SRC}/include/klibc/)
include_directories(${MENIX_SRC}/kernel/arch/${MENIX_ARCH}/include/)

set_target_properties(menix
	PROPERTIES
	ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
	LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
	RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

# Main subsystems.
add_subdirectory(arch/${MENIX_ARCH_DIR})
add_subdirectory(klibc)
add_subdirectory(drv)
add_subdirectory(fs)
add_subdirectory(sys)
target_link_libraries(menix PUBLIC
	menix_arch_${MENIX_ARCH_DIR}
	menix_klibc
	menix_drv
	menix_fs
	menix_sys
)

# Other subsystems.
add_subdirectory(video)
target_link_libraries(menix PUBLIC
	menix_video
)
