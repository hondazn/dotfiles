// カーソルの四角形範囲を一瞬真っ黒にするエフェクト
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // 元の色を取得
    fragColor = texture(iChannel0, fragCoord.xy / iResolution.xy);
    
    float elapsed = iTime - iTimeCursorChange;
    
    // 短い持続時間でフェードイン/アウト
    float duration = 0.35;
    float fadeIn = smoothstep(0.0, 0.02, elapsed);
    float fadeOut = 1.0 - smoothstep(0.05, duration, elapsed);
    float fade = fadeIn * fadeOut;
    
    // フェードが0なら早期終了
    if (fade < 0.001) return;
    
    // カーソルの位置とサイズを取得
    vec2 cursorPos = iCurrentCursor.xy;
    vec2 cursorSize = iCurrentCursor.zw;
    
    // カーソルのオフセットを適用
    vec2 adjustedCursorPos = vec2(
        cursorPos.x + cursorSize.x * 0.5,
        cursorPos.y - cursorSize.y * 0.5
    );
    
    // カーソルの矩形範囲内かチェック
    vec2 localPos = fragCoord - adjustedCursorPos;
    bool insideCursor = abs(localPos.x) <= cursorSize.x * 0.5 &&
                        abs(localPos.y) <= cursorSize.y * 0.5;
    
    // カーソル範囲内のみ黒くする
    if (insideCursor) {
        fragColor.rgb = mix(fragColor.rgb, vec3(0.0), fade);
    }
}
