let cmake#data#operators#conditional =<< DATA
{
  filesystem: [
    "IS_NEWER_THAN",
    "IS_DIRECTORY",
    "IS_ABSOLUTE",
    "IS_SYMLINK",
    "EXISTS"
  ],
  version: [
    "VERSION_GREATER_EQUAL",
    "VERSION_LESS_EQUAL",
    "VERSION_GREATER",
    "VERSION_EQUAL",
    "VERSION_LESS"
  ],
  compare: [
    "GREATER_EQUAL",
    "LESS_EQUAL",
    "GREATER",
    "EQUAL",
    "LESS"
  ],
  string: [
    "STRGREATER_EQUAL",
    "STRLESS_EQUAL",
    "STRGREATER",
    "STREQUAL",
    "STRLESS",
  ],
  check: [
    "IN_LIST",
    "DEFINED",
    "COMMAND",
    "MATCHES",
    "POLICY",
    "TARGET",
    "TEST"
  ],
  basic: [
    "NOT",
    "AND",
    "OR"
  ]
}
DATA

let cmake#data#operators#repeat =<< DATA
[
  'RANGE',
  'LISTS',
  'ITEMS',
  'IN'
]
DATA

let cmake#data#operators#generator =<< DATA
{
  logical: [
    "BOOL",
    "AND",
    "OR",
    "NOT"
  ],
  compare: [
    "STREQUAL",
    "EQUAL",
    "IN_LIST",
    "VERSION_LESS",
    "VERSION_GREATER",
    "VERSION_EQUAL",
    "VERSION_LESS_EQUAL",
    "VERSION_GREATER_EQUAL"
  ],
  query: [
    "TARGET_EXISTS",
    "CONFIG",
    "PLATFORM_ID",
    "C_COMPILER_ID",
    "CXX_COMPILER_ID",
    "CUDA_COMPILER_ID",
    "OBJC_COMPILER_ID",
    "OBJCXX_COMPILER_ID",
    "Fortran_COMPILER_ID",
    "C_COMPILER_VERSION",
    "CXX_COMPILER_VERSION",
    "CUDA_COMPILER_VERSION",
    "OBJC_COMPILER_VERSION",
    "OBJCXX_COMPILER_VERSION",
    "Fortran_COMPILER_VERSION",
    "TARGET_POLICY",
    "COMPILE_FEATURES",
    "COMPILE_LANG_AND_ID",
    "COMPILE_LANGUAGE"
  ],
  escape: [
    "ANGLE-R",
    "COMMA",
    "SEMICOLON"
  ],
  conditional: [
    "IF"
  ],
  transformations: [
    "JOIN",
    "REMOVE_DUPLICATES",
    "FILTER",
    "LOWER_CASE",
    "UPPER_CASE",
    "TARGET_GENEX_EVAL",
    "GENEX_EVAL "
  ],
  target: [
    "TARGET_NAME_IF_EXISTS",
    "TARGET_FILE",
    "TARGET_FILE_BASE_NAME",
    "TARGET_FILE_PREFIX",
    "TARGET_FILE_SUFFIX",
    "TARGET_FILE_NAME",
    "TARGET_FILE_DIR",
    "TARGET_LINKER_FILE",
    "TARGET_LINKER_FILE_BASE_NAME",
    "TARGET_LINKER_FILE_PREFIX",
    "TARGET_LINKER_FILE_SUFFIX",
    "TARGET_LINKER_FILE_NAME",
    "TARGET_LINKER_FILE_DIR",
    "TARGET_SONAME_FILE",
    "TARGET_SONAME_FILE_NAME",
    "TARGET_SONAME_FILE_DIR",
    "TARGET_PDB_FILE",
    "TARGET_PDB_FILE_NAME",
    "TARGET_PDB_FILE_DIR",
    "TARGET_BUNDLE_DIR",
    "TARGET_BUNDLE_CONTENT_DIR",
    "TARGET_PROPERTY",
    "INSTALL_PREFIX"
  ],
  output: [
    "TARGET_NAME",
    "LINK_ONLY",
    "INSTALL_INTERFACE",
    "BUILD_INTERFACE",
    "MAKE_C_IDENTIFIER",
    "TARGET_OBJECTS",
    "SHELL_PATH"
  ]
}

DATA
