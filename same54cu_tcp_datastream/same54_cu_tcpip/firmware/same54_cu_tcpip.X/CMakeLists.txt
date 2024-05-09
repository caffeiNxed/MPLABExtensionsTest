cmake_minimum_required(VERSION 3.10)
set(CMAKE_SYSTEM_NAME "Generic")
set(CMAKE_TOOLCHAIN_FILE .cmakefiles_${PROJ}/toolchain.cmake)
project(${PROJ}.X LANGUAGES  C CXX ASM)

# can we move these canned values to xc23-rules.cmake?
set(CMAKE_C_FLAGS "")
set(CMAKE_C_FLAGS_DEBUG "")
set(CMAKE_C_FLAGS_RELEASE "")
set(CMAKE_CXX_FLAGS_RELEASE "")
set(CMAKE_CXX_FLAGS_DEBUG "")
set(CMAKE_ASM_FLAGS_RELEASE "")
set(CMAKE_ASM_FLAGS_DEBUG "")
set(CMAKE_EXPORT_COMPILE_COMMANDS "ON")

include(.cmakefiles_${PROJ}/settings.cmake)
include(.cmakefiles_${PROJ}/xc32-rules.cmake)
include(.cmakefiles_${PROJ}/files.cmake)
include(.cmakefiles_${PROJ}/emissions.cmake)

set(library_list "")

# c files
foreach(file_group ${FILE_GROUPS_c})
    list(FIND FILE_GROUPS ${file_group} index)
    list(GET FILE_GROUPS ${index} val)
    string(REPLACE "_files" "" group_name ${file_group})
    if ("${${file_group}}" STREQUAL "")
        #message("Skipping empty group ${file_group}")
    else()
        add_library(${group_name}  OBJECT ${${file_group}})
        compile_rule(${group_name})
        set(library_list ${library_list} "$<TARGET_OBJECTS:${group_name}>")
    endif()
endforeach()

# s files
foreach(file_group ${FILE_GROUPS_s})
    list(FIND FILE_GROUPS ${file_group} index)
    list(GET FILE_GROUPS ${index} val)
    string(REPLACE "_files" "" group_name ${file_group})
    if ("${${file_group}}" STREQUAL "")
        #message("Skipping empty group ${file_group}")
    else()
        add_library(${group_name}  OBJECT ${${file_group}})
        assemble_rule(${group_name})
        set(library_list ${library_list} "$<TARGET_OBJECTS:${group_name}>")
    endif()
endforeach()

# S files
foreach(file_group ${FILE_GROUPS_S})
    list(FIND FILE_GROUPS ${file_group} index)
    list(GET FILE_GROUPS ${index} val)
    string(REPLACE "_files" "" group_name ${file_group})
    if ("${${file_group}}" STREQUAL "")
        #message("Skipping empty group ${file_group}")
    else()
        add_library(${group_name}  OBJECT ${${file_group}})
        S_rule(${group_name})
        set(library_list ${library_list} "$<TARGET_OBJECTS:${group_name}>")
    endif()
endforeach()

# cc files
foreach(file_group ${FILE_GROUPS_cc})
    list(FIND FILE_GROUPS ${file_group} index)
    list(GET FILE_GROUPS ${index} val)
    string(REPLACE "_files" "" group_name ${file_group})
    if ("${${file_group}}" STREQUAL "")
        #message("Skipping empty group ${file_group}")
    else()
        add_library(${group_name}  OBJECT ${${file_group}})
        cc_compile_rule(${group_name})
        set(library_list ${library_list} "$<TARGET_OBJECTS:${group_name}>")
    endif()
endforeach()

add_executable(${image_name} ${library_list})
link_rule(${image_name})
add_custom_target(
    Bin2Hex
    ALL
    ${MP_BIN2HEX} ${image_name}
)
add_dependencies(Bin2Hex ${image_name})

add_custom_command(
  TARGET ${image_name}
  COMMAND ${CMAKE_COMMAND} -E make_directory ${output_dir}
  COMMAND ${CMAKE_COMMAND} -E copy ${image_name} ${output_dir})