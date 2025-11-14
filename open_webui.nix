{ hosts, ... } :

{
  networking = {
    # networkmanager.dns = "none";
    # useDHCP = false;
    # dhcpcd.enable = false;
    
    # hosts = {
    #   "192.168.8.125" = ["xps"];
    # };
    firewall.interfaces."${hosts.interface}" = {
      allowedTCPPorts = [ 80 443 ];
    };
    # nameservers = ["192.168.8.125" "8.8.8.8"];
  };
  services = {
    # resolved = {
    #   enable = true;
    #   domains = [
    #     "XPS-9530.local"
    #     "~.local"
    #   ];
    # };
    # dnsmasq = {
    #   enable = true;
    # };
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."${hosts.hostName}" = {
      locations."/" = {
        proxyWebsockets = true;
        proxyPass = "http://127.0.0.1:8080";
      };
      };
    };
    ollama = {
      enable = true;
      acceleration = "cuda";
      loadModels = [
        "gemma3:1b"
        "gemma3:4b"
      ];
    };
    open-webui.enable = true;
  };
}
