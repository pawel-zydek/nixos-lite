{ ... }:
{
  # Terminal foot - natywny dla Waylanda, bardzo lekki.
  # Serwer foot działa w tle, a każde okno (footclient, Mod+Enter) to tylko kilka MB:
  # wszystkie okna dzielą czcionki i pamięć podręczną glifów.
  programs.foot = {
    enable = true;
    server.enable = true;
    settings = {
      main = {
        font = "DejaVu Sans Mono:size=10";
        pad = "4x4";
      };
      scrollback.lines = 5000;
      mouse.hide-when-typing = "yes";
    };
  };
}
