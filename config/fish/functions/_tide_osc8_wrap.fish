function _tide_osc8_wrap --argument-names url text
    printf '\e]8;;%s\e\\' "$url"
    echo -ns $text
    printf '\e]8;;\e\\'
end
