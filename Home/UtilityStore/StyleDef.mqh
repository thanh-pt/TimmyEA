#define LINE_STYLE          ENUM_LINE_STYLE

enum ELineStyle {
    eLineDot        ,   //Dot
    eLineSolid1     ,   //Solid
    eLineDash       ,   //Dash
    eLineDashDot    ,   //DashDot
    eLineDashDotDot ,   //DashDotDot
    eLineSolid2     ,   //Solid Bold
    eLineSolid3     ,   //Solid Extra Bold
    eLineSolid4     ,   //Solid Ultra Bold
    eLineSolid5     ,   //Solid Extreme Bold
};

int getLineWidth(ELineStyle eLineStyle){
    switch (eLineStyle) {
        case eLineDot       : return 1;
        case eLineSolid1    : return 1;
        case eLineDash      : return 1;
        case eLineDashDot   : return 1;
        case eLineDashDotDot: return 1;
        case eLineSolid2    : return 2;
        case eLineSolid3    : return 3;
        case eLineSolid4    : return 4;
        case eLineSolid5    : return 5;
    }
    return 0;
}

int getLineStyle(ELineStyle eLineStyle){
    switch (eLineStyle) {
        case eLineDot       : return STYLE_DOT  ;
        case eLineSolid1    : return STYLE_SOLID;
        case eLineDash      : return STYLE_DASH ;
        case eLineDashDot   : return STYLE_DASHDOT;
        case eLineDashDotDot: return STYLE_DASHDOTDOT;
        case eLineSolid2    : return STYLE_SOLID;
        case eLineSolid3    : return STYLE_SOLID;
        case eLineSolid4    : return STYLE_SOLID;
        case eLineSolid5    : return STYLE_SOLID;
    }
    return STYLE_SOLID;
}