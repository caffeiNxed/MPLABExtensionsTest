if (DEBUG)
    set(IMAGE_TYPE "debug")
else()
    set(IMAGE_TYPE "production")
endif()

function(get_value_for_opt_group target group_name ret separator)
     set(target_option_names "${target}_OPTION_NAMES")
     set(target_option_values "${target}_OPTION_VALUES")
     set(group_name_with_target "${target}.${group_name}")
     list(FIND ${target_option_names} ${group_name_with_target} INDEX_INTO_OPT_GROUPS)
     if(${INDEX_INTO_OPT_GROUPS} EQUAL -1)
          message(FATAL_ERROR "Could not find ${group_name_with_target} in ${target_option_names}")
     endif()
     list(GET ${target_option_values} ${INDEX_INTO_OPT_GROUPS} GROUP_VALUE)
     if(${GROUP_VALUE} MATCHES "NOTFOUND")
          message(FATAL_ERROR "Could not find index ${INDEX_INTO_OPT_GROUPS} in ${target_option_values}")
     endif()
     if (${GROUP_VALUE} MATCHES ".*___SEPARATOR___.*")
          string(REPLACE ${SPACE_SEPARATOR_FOR_OPTIONS} "${separator}" EXPANDED_GROUP_VALUE ${GROUP_VALUE})
     else()
          set(EXPANDED_GROUP_VALUE ${GROUP_VALUE})
     endif()
     if ("${EXPANDED_GROUP_VALUE}" STREQUAL "${separator}")
          set(EXPANDED_GROUP_VALUE "")
     endif()
     set(${ret} ${EXPANDED_GROUP_VALUE} PARENT_SCOPE)
endfunction()

function(cc_compile_rule target)

     if (LTO)
          target_compile_options(${target} PRIVATE "-flto;-fwhole-program")
     endif()

     if (DEBUG)
          target_compile_options(${target} PRIVATE "-g;-D__DEBUG;${DEBUGGER_NAME_AS_MACRO};")
     endif()

     if (DEBUG AND NOT IS_ARM)
          target_compile_options(${target} PRIVATE "-fframe-base-loclist")
     endif()

     if (NOT DEBUG)
          get_value_for_opt_group(${target} "C32CPP.symbols-on-release" ret ";")
          target_compile_options(${target} PRIVATE ${ret})
     endif()

     target_compile_options(${target} PRIVATE "-x;c++;-c;-mprocessor=${MP_PROCESSOR_OPTION}")

     get_value_for_opt_group(${target} "C32Global.common-include-dirs" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     #<mp:textEmitter  mp:if="${IS_MASTER}" mp:text=" ${SLAVE_HEADER_FOLDERS} "/>
     # UNIMPLEMENTED

     get_value_for_opt_group(${target} "C32CPP.ungrouped" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     get_value_for_opt_group(${target} "C32-CO.coverage" ret ";")
     target_compile_options(${target} PRIVATE ${ret})
     get_value_for_opt_group(${target} "C32-CO.stackguidance" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     #<mp:textEmitter  mp:text="${INSTRUMENTED_TRACE_OPTIONS} "/>
     # UNIMPLEMENTED


     get_value_for_opt_group(${target} "C32Global.both" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     target_compile_options(${target} PRIVATE "-D${MPLABX_ACTIVE_CFG}=${CND_CONF}")

     if (COMPARISON_BUILD)
          target_compile_options(${target} PRIVATE "${COMPARISON_BUILD}")
     endif()

     get_value_for_opt_group(${target} "C32Global.gp-relative-treshhold" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     get_value_for_opt_group(${target} "C32Global.appendMe" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     get_value_for_opt_group(${target} "C32CPP.appendMe" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     target_compile_options(${target} PRIVATE "${MDFP_PATH}")

     target_compile_options(${target} PRIVATE "${CMSIS_PACK_INCLUDE}")
endfunction()

function(assemble_rule target)

     if (LTO)
          target_compile_options(${target} PRIVATE "-flto;-fwhole-program")
     endif()

     if (DEBUG)
          target_compile_options(${target} PRIVATE "-g;-D__DEBUG;${DEBUGGER_NAME_AS_MACRO};")
     endif()

     target_compile_options(${target} PRIVATE ";-c;-mprocessor=${MP_PROCESSOR_OPTION}")

     get_value_for_opt_group(${target} "C32-AS.pre" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     get_value_for_opt_group(${target} "C32Global.appendMe" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     target_compile_options(${target} PRIVATE "-Wa,--defsym=__MPLAB_BUILD=1")

     if (DEBUG and NOT SIMULATOR)
          target_compile_options(${target} PRIVATE "-Wa,--defsym=__ICD2RAM=1")
     endif()

     if (DEBUG)
     target_compile_options(${target} PRIVATE "-Wa,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1,${DEBUGGER_NAME_AS_SYMBOL}")
     endif()

     get_value_for_opt_group(${target} "C32-AS.symbols-on-release" ret ",")
     if (NOT "${ret}" STREQUAL "")
          target_compile_options(${target} PRIVATE "-Wa,${ret}")
     endif()

     get_value_for_opt_group(${target} "C32-AS.post" ret ",")
     if (NOT "${ret}" STREQUAL "")
     target_compile_options(${target} PRIVATE "-Wa,${ret}")
     endif()

     get_value_for_opt_group(${target} "C32Global.common-include-dirs" ret ",")
     if (NOT "${ret}" STREQUAL "")
          target_compile_options(${target} PRIVATE "-Wa,${ret}")
     endif()


     #<mp:textEmitter mp:if="${IS_MASTER}" mp:text=" ${SLAVE_HEADER_FOLDERS} "/>

     get_value_for_opt_group(${target} "C32-AS.postlist" ret ",")
     if (NOT "${ret}" STREQUAL "")
     target_compile_options(${target} PRIVATE "-Wa,${ret}")
     endif()

     get_value_for_opt_group(${target} "C32-AS.appendMe" ret ",")
     if (NOT "${ret}" STREQUAL "")
     target_compile_options(${target} PRIVATE "-Wa,${ret}")
     endif()

     target_compile_options(${target} PRIVATE "${MDFP_PATH}")
endfunction()

function(S_rule target)

     if (LTO)
          target_compile_options(${target} PRIVATE "-flto;-fwhole-program")
     endif()

     if (DEBUG)
          target_compile_options(${target} PRIVATE "-g;-D__DEBUG;${DEBUGGER_NAME_AS_MACRO};")
     endif()

     target_compile_options(${target} PRIVATE ";-c;-mprocessor=${MP_PROCESSOR_OPTION}")

     get_value_for_opt_group(${target} "C32-AS.pre" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     get_value_for_opt_group(${target} "C32Global.both" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     target_compile_options(${target} PRIVATE "-D${MPLABX_ACTIVE_CFG}=${CND_CONF}")

     if(NOT project_cpp)
          target_compile_options(${target} PRIVATE "${LEGACY_LIBC}")
     endif()

     get_value_for_opt_group(${target} "C32Global.appendMe" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     target_compile_options(${target} PRIVATE "-Wa,--defsym=__MPLAB_BUILD=1")

     if (DEBUG AND (NOT SIMULATOR))
          target_compile_options(${target} PRIVATE "-Wa,--defsym=__ICD2RAM=1")
     endif()

     if (DEBUG)
          target_compile_options(${target} PRIVATE "-Wa,--defsym=__MPLAB_DEBUG=1,--gdwarf-2,--defsym=__DEBUG=1,${DEBUGGER_NAME_AS_SYMBOL}")
     endif()

     get_value_for_opt_group(${target} "C32-AS.symbols-on-release" ret ",")
     if (NOT "${ret}" STREQUAL "")
          target_compile_options(${target} PRIVATE "-Wa,${ret}")
     endif()

     get_value_for_opt_group(${target} "C32Global.common-include-dirs" ret ",")
     if (NOT "${ret}" STREQUAL "")
          target_compile_options(${target} PRIVATE "-Wa,${ret}")
     endif()

#<mp:textEmitter mp:if="${IS_MASTER}" mp:text=" ${SLAVE_HEADER_FOLDERS} "/>

     get_value_for_opt_group(${target} "C32-AS.post" ret ",")
     if (NOT "${ret}" STREQUAL "")
          target_compile_options(${target} PRIVATE "-Wa,${ret}")
     endif()

     get_value_for_opt_group(${target} "C32-AS.postlist" ret ",")
     if (NOT "${ret}" STREQUAL "")
          target_compile_options(${target} PRIVATE "-Wa,${ret}")
     endif()

     get_value_for_opt_group(${target} "C32-AS.appendMe" ret ",")
     if (NOT "${ret}" STREQUAL "")
          target_compile_options(${target} PRIVATE "-Wa,${ret}")
     endif()

     target_compile_options(${target} PRIVATE "${MDFP_PATH}")
endfunction()

function(compile_rule target)

     if (LTO)
          target_compile_options(${target} PRIVATE "-flto;-fwhole-program")
     endif()
     
     if (DEBUG)
          target_compile_options(${target} PRIVATE "-g;-D__DEBUG;${DEBUGGER_NAME_AS_MACRO};")
     endif()

     if (DEBUG AND NOT IS_ARM)
          target_compile_options(${target} PRIVATE "-fframe-base-loclist")
     endif()

     if (NOT DEBUG)
          get_value_for_opt_group(${target} "C32.symbols-on-release" ret ";")
          target_compile_options(${target} PRIVATE ${ret})
     endif()

     target_compile_options(${target} PRIVATE "-x;c;-c;-mprocessor=${MP_PROCESSOR_OPTION}")

     get_value_for_opt_group(${target} "C32Global.common-include-dirs" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     #<mp:textEmitter  mp:if="${IS_MASTER}" mp:text=" ${SLAVE_HEADER_FOLDERS} "/>
     # UNIMPLEMENTED

     get_value_for_opt_group(${target} "C32.ungrouped" ret ";")
     target_compile_options(${target} PRIVATE ${ret})
     
     get_value_for_opt_group(${target} "C32-CO.coverage" ret ";")
     target_compile_options(${target} PRIVATE ${ret})
     get_value_for_opt_group(${target} "C32-CO.stackguidance" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     #<mp:textEmitter  mp:text="${INSTRUMENTED_TRACE_OPTIONS} "/>
     #<mp:textEmitter  mp:text="${FUNCTION_LEVEL_PROFILING_OPTIONS} "/>
     # UNIMPLEMENTED


     get_value_for_opt_group(${target} "C32Global.both" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     target_compile_options(${target} PRIVATE "-D${MPLABX_ACTIVE_CFG}=${CND_CONF}")

     if(NOT project_cpp)
          target_compile_options(${target} PRIVATE "${LEGACY_LIBC}")
     endif()

     if (COMPARISON_BUILD)
          target_compile_options(${target} PRIVATE "${COMPARISON_BUILD}")
     endif()

     get_value_for_opt_group(${target} "C32Global.gp-relative-treshhold" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     get_value_for_opt_group(${target} "C32Global.appendMe" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     get_value_for_opt_group(${target} "C32.appendMe" ret ";")
     target_compile_options(${target} PRIVATE ${ret})

     target_compile_options(${target} PRIVATE "${MDFP_PATH}")

     target_compile_options(${target} PRIVATE "${CMSIS_PACK_INCLUDE}")
endfunction()


# link_rule
#    This function will update the target_link_options for all files in ${_file_group_sources}
#  param: target the file to be linked as image
function(link_rule target)
     if (LTO)
          target_link_options(${target} PRIVATE "-flto;-fwhole-program")
     endif()

     if (DEBUG)
          target_link_options(${target} PRIVATE "-g;-D__DEBUG;${DEBUGGER_NAME_AS_MACRO}")
     endif()

     target_link_options(${target} PRIVATE "-mprocessor=${MP_PROCESSOR_OPTION}")

     get_value_for_opt_group("linker" "C32-LD.pre" ret ";")
     target_link_options(${target} PRIVATE ${ret})

     get_value_for_opt_group("linker" "C32-LD.ld-extra" ret ";")
     target_link_options(${target} PRIVATE ${ret})

##<mp:textEmitter mp:text=" ${INSTRUMENTED_TRACE_OPTIONS} "/>
##<mp:textEmitter mp:text=" ${FUNCTION_LEVEL_PROFILING_OPTIONS} "/>
## UNIMPLEMENTED

     get_value_for_opt_group("project_c" "C32Global.both" ret ";")
     target_link_options(${target} PRIVATE ${ret})


     target_link_options(${target} PRIVATE "-D${MPLABX_ACTIVE_CFG}=${CND_CONF}")

##<mp:textEmitter mp:ifnot="${project_cpp}" mp:text=" ${LEGACY_LIBC} "/>
#if(NOT project_cpp)
#     target_link_options(${target} PRIVATE " ${LEGACY_LIBC}"  "" "")
#endif()

     get_value_for_opt_group("project_c" "C32Global.appendMe" ret ";")
     target_link_options(${target} PRIVATE ${ret})

#<mp:optionEmitter mp:idref="C32Global" opt:groupidref="linker" mp:separator=" "/>
# NOTE: I did not find any group with name linker!!!!!!!!!!!
#     get_value_for_opt_group(${target} "C32Global.linker" ret)
#     target_link_options(${target} PRIVATE ${ret})

     
#<mp:textEmitter mp:if="${IS_MASTER}" mp:text=" ${SLAVE_HEADER_FOLDERS} "/>
## UNIMPLEMENTED
#

     get_value_for_opt_group("project_c" "C32-CO.stackguidance" ret ";")
     target_link_options(${target} PRIVATE ${ret})

     if (COMPARISON_BUILD)
          target_compile_options(${target} PRIVATE "${COMPARISON_BUILD}")
     endif()


## UNIMPLEMENTED
#
##<mp:textEmitter mpworkspace_compiler_flags:if="${HAS_DEBUG_RANGES}" mp:onlydebug="true" mp:text=" ${DEBUG_MEMORY_RANGES} "/>
#if(HAS_DEBUG_RANGES AND DEBUG)
#     target_link_options(${target} PRIVATE " ${DEBUG_MEMORY_RANGES} "  "" "")
#endif()
#

     target_link_options(${target} PRIVATE "-Wl,--defsym=__MPLAB_BUILD=1")

     ##<mp:textEmitter mp:text="$(MP_EXTRA_LD_POST)"/>
#
##<mp:textEmitter mp:if="${IS_MASTER}" mp:onlydebug="true" mp:text=",${SLAVE_DEBUG_BITS}"/>
## UNIMPLEMENTED

if(NOT MP_LINKER_FILE_OPTION STREQUAL "")
     target_link_options(${target} PRIVATE "-Wl,${MP_LINKER_FILE_OPTION}")
endif()

##<mp:textEmitter mp:ifnot="${SIMULATOR} || ${HAS_DEBUG_RANGES}" mp:onlydebug="true" mp:text=",--defsym=__ICD2RAM=1"/>
#if (DEBUG AND (NOT SIMULATOR OR HAS_DEBUG_RANGES))
#     target_link_options(${target} PRIVATE ",--defsym=__ICD2RAM=1" "" "")
#endif()
#


if (DEBUG)
     target_compile_options(${target} PRIVATE "-Wl,--defsym=__MPLAB_DEBUG=1,--defsym=__DEBUG=1${CHIPKIT_DEBUG_SYMBOL},${DEBUGGER_NAME_AS_SYMBOL}")
endif()

     get_value_for_opt_group("linker" "C32-LD.post" ret ",")
     if(NOT ${ret} STREQUAL "")
          target_link_options(${target} PRIVATE "-Wl,${ret}")
     endif()

#
##<mp:textEmitter mp:text="${IDE_DASHBOARD}"/>
## UNIMPLEMENTED

     get_value_for_opt_group("linker" "C32-LD.appendMe" ret ";")
     target_link_options(${target} PRIVATE ${ret})

     target_link_options(${target} PRIVATE "${MDFP_PATH}")

endfunction()