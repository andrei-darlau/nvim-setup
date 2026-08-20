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
[
  (kw_process)
  (kw_postponed)
] @keyword.repeat

; --- begin/end as block delimiters, matching { } in C ----------------------
; VHDL uses begin/end far more than Verilog does (entity, architecture,
; process, package body, subprogram bodies, generate, block ...) so this is
; the single highest-value line in the file.
[
  (kw_begin)
  (kw_end)
] @punctuation.bracket

; --- real brackets, in case the base query misses them ---------------------
[
  "("
  ")"
  "["
  "]"
] @punctuation.bracket

; --- clock edges: the VHDL posedge/negedge ---------------------------------
; These are ordinary function calls from ieee.std_logic_1164, not keywords, so
; they have to be matched by name. VHDL is case-insensitive and everyone
; spells these differently, hence the list.
((simple_name) @keyword.edge
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
; ALTERNATIVE NODE-NAME CONVENTIONS
;
; (a) UPPERCASE named rules -- replace the first two blocks with:
;
;     [(PROCESS) (POSTPONED)] @keyword.repeat
;     [(BEGIN) (END)] @punctuation.bracket
;
; (b) plain string literals (only possible if the grammar is case-sensitive
;     or lowercases tokens) -- replace with:
;
;     ["process" "postponed"] @keyword.repeat
;     ["begin" "end"] @punctuation.bracket
;
; Likewise, if (simple_name) is rejected, the identifier node is probably
; (identifier) or (name) -- :InspectTree on a call to rising_edge() will say.
; ---------------------------------------------------------------------------
