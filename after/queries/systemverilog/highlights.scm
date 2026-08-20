; extends

; give always/initial blocks their own color
["always" "always_comb" "always_ff" "always_latch" "initial"] @keyword.repeat

; treat begin/end like block delimiters (so they match each other, like { })
["begin" "end"] @punctuation.bracket

; make sure real brackets are colored even if the base query misses them
["(" ")" "[" "]" "{" "}"] @punctuation.bracket

["posedge" "negedge"] @keyword.edge
