ENTRY(_start)
SECTIONS
{
  . = 0x400000 + SIZEOF_HEADERS;  /* 设置当前位置的 VMA */
  main : { *(.text) *(.rodata) }  /* 将所有输入目标文件中的 .text 与 .rodata 段合并到 main 段中 */
  /DISCARD/ : { *(.symtab) *(.strtab) }
}
