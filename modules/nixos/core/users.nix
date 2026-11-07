{ ... }:
{
  # Konto systemowe. Dodatkowe grupy dopisują
  # moduły, które ich potrzebują.
  users.users.pawel = {
    isNormalUser = true;
    description = "Paweł Żydek";
    extraGroups = [ "wheel" "networkmanager" "video" ];   # video: jasność ekranu
  };

  networking.networkmanager.enable = true;
}
