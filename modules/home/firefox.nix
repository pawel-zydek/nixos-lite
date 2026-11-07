{ ... }:
{
  programs.firefox = {
    enable = true;

    languagePacks = [ "pl" ];

    policies = {
      DisableTelemetry = true;
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false;
    };

    profiles.default = {
      isDefault = true;
      settings = {
        "browser.startup.homepage" = "about:blank";
        "intl.accept_languages" = "pl, en-US, en";
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

        # --- Mniej RAM-u i CPU na starym laptopie ---
        "dom.ipc.processCount" = 4;                  # mniej procesów na karty (domyślnie 8)
        "browser.tabs.unloadOnLowMemory" = true;     # usypianie nieużywanych kart przy braku pamięci
        "browser.sessionstore.interval" = 60000;     # zapis sesji co 60 s zamiast co 15 s
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "media.ffmpeg.vaapi.enabled" = true;         # sprzętowe dekodowanie wideo (VA-API)
        "widget.use-xdg-desktop-portal.file-picker" = 1;   # okno wyboru plików przez portal
      };
    };
  };
}
