#define LINE_STYLE          ENUM_LINE_STYLE

enum ELineStyle {
    eLineDot            , // Dot
    eLineSolid          , // Solid
    eLineDash           , // Dash
    eLineDashDot        , // Dash Dot
    eLineDashDotDot     , // Dash Dot Dot
    eLineBold           , // Bold
    eLineExtraBold      , // Extra Bold
    eLineUltraBold      , // Ultra Bold
    eLineExtremeBold    , // Extreme Bold
};

int getLineWidth(ELineStyle eLineStyle){
    switch (eLineStyle) {
        case eLineDot           : return 1;
        case eLineSolid         : return 1;
        case eLineDash          : return 1;
        case eLineDashDot       : return 1;
        case eLineDashDotDot    : return 1;
        case eLineBold          : return 2;
        case eLineExtraBold     : return 3;
        case eLineUltraBold     : return 4;
        case eLineExtremeBold   : return 5;
    }
    return 0;
}

int getLineStyle(ELineStyle eLineStyle){
    switch (eLineStyle) {
        case eLineDot           : return STYLE_DOT  ;
        case eLineSolid         : return STYLE_SOLID;
        case eLineDash          : return STYLE_DASH ;
        case eLineDashDot       : return STYLE_DASHDOT;
        case eLineDashDotDot    : return STYLE_DASHDOTDOT;
        case eLineBold          : return STYLE_SOLID;
        case eLineExtraBold     : return STYLE_SOLID;
        case eLineUltraBold     : return STYLE_SOLID;
        case eLineExtremeBold   : return STYLE_SOLID;
    }
    return STYLE_SOLID;
}