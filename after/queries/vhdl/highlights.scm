; extends
;
; Goes in:  ~/.config/nvim/after/queries/vhdl/highlights.scm
;
; VHDL counterpart of your verilog highlights.scm. It deliberately reuses the
; SAME capture names, so the tokyonight on_highlights block colors both
; languages identically with no extra Lua:
;
;   verilog                        vhdl                         capture / color
;   -----------------------------  ---------------------------  ---------------------------
;   always / always_ff / initial   process / postponed process  @keyword.repeat      magenta
;   begin / end                    begin / end                  @punctuation.bracket teal
;   ( ) [ ] { }                    ( ) [ ]                      @punctuation.bracket teal
;   posedge / negedge              rising_edge / falling_edge   @keyword.edge        yellow
;
; ---------------------------------------------------------------------------
; IF THIS FILE ERRORS WHEN YOU OPEN A .vhd
;
; VHDL is case-insensitive, so the grammar cannot store keywords as plain
; string literals the way the verilog grammar does ("always" etc). It wraps
; each reserved word in a named rule instead. The names below (kw_process,
; kw_begin, ...) are the convention the vhdl grammar uses, but grammars get
; regenerated and an unknown node name makes Neovim reject the WHOLE file with
; a "invalid node type" query error.
;
; If that happens, in a VHDL buffer run:
;     :VhdlTsSymbols process     (helper defined in init.lua)
;     :InspectTree               (put the cursor on process / begin / end)
; and swap the names below for what you see. Two alternative conventions are
; commented at the bottom of this file -- one of the three will be right.
; ---------------------------------------------------------------------------

; --- process blocks: the VHDL "always" ------------------------------------
; Confirmed against jpt13653903/tree-sitter-vhdl's own queries/Neovim/
; highlights.scm: "process"/"postponed" are plain anonymous string tokens,
; not named nodes -- the grammar's scanner normalises case itself, so a
; plain string literal here matches regardless of how the user cased it.
[
  "process"
  "postponed"
] @keyword.repeat

; --- begin/end as block delimiters, matching { } in C ----------------------
; VHDL uses begin/end far more than Verilog does (entity, architecture,
; process, package body, subprogram bodies, generate, block ...) so this is
; the single highest-value line in the file.
[
  "begin"
  "end"
] @punctuation.bracket

; --- real brackets, in case the base query misses them ---------------------
[
  "("
  ")"
  "["
  "]"
] @punctuation.bracket

; --- clock edges: the VHDL posedge/negedge ---------------------------------
; These are ordinary function calls from ieee.std_logic_1164, not keywords,
; and there's no dedicated call/function-name node worth targeting here --
; the grammar just wraps the callee in a generic (_) "function:" field. It's
; simplest (and matches the base query's own style) to key off plain
; (identifier) text. This pattern is appended after the base query's
; `(identifier) @variable`, so for these specific names it wins.
((identifier) @keyword.edge
  (#any-of? @keyword.edge
    "rising_edge" "RISING_EDGE" "Rising_Edge"
    "falling_edge" "FALLING_EDGE" "Falling_Edge"))

; ---------------------------------------------------------------------------
; OPTIONAL EXTRAS -- uncomment once you've confirmed the node names above.
;
; The 'event / 'last_value style clock idiom (clk'event and clk = '1'):
;
; ((attribute_name (simple_name) @keyword.edge)
;   (#any-of? @keyword.edge "event" "EVENT" "stable" "STABLE"))
;
; Entity ports and generics in orange, like verilog's @variable.parameter:
;
; (interface_signal_declaration (identifier_list (identifier) @variable.parameter))
; (interface_constant_declaration (identifier_list (identifier) @variable.parameter))
;
; Record field access in cyan, like verilog's @property:
;
; (selected_name suffix: (simple_name) @property)
; ---------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; CONFIRMED against jpt13653903/tree-sitter-vhdl's own queries/Neovim/
; highlights.scm (fetched from the tree-sitter-vhdl sdist on PyPI):
; keywords are plain lowercase string literals ("process", "begin", "end",
; ...), and plain identifiers are (identifier), not (simple_name). That's
; convention (b) above, and it's what this file now uses.
; ---------------------------------------------------------------------------
