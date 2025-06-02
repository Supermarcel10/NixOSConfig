{ pkgs, ... }:

let
        lock-false = {
                Value = false;
                Status = "locked";
        };
        lock-true = {
                Value = true;
                Status = "locked";
        };
in
{
	programs.firefox = {
		enable = true;
		package = pkgs.firefox-wayland;

		/* ---- POLICIES ---- */
		# Check about:policies#documentation for options.
		policies = {
			DisableTelemetry = true;
			DisableFirefoxStudies = true;
			EnableTrackingProtection = {
				Value = true;
				Locked = true;
				Cryptomining = true;
				Fingerprinting = true;
			};
			DisablePocket = true;
			DisableFirefoxScreenshots = true;
			DontCheckDefaultBrowser = true;
			DisplayBookmarksToolbar = "always";

			/* ---- PREFERENCES ---- */
			# Check about:config for options.
			Preferences = {
				"extensions.pocket.enabled" = lock-false;
				"extensions.screenshots.disabled" = lock-true;
				"browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
				"browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
				"browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
				"browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
				"browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
				"browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
				"browser.newtabpage.activity-stream.showSponsored" = lock-false;
				"browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
				"browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;

				# Tab Groups
				"browser.tabs.groups.enabled" = lock-true;

				# Performance Tweaks
				# TODO: Make forced GPU acceleration for devices with dedicated GPU rather than all
				# "gfx.webrender.all" = lock-true;
				# "layers.acceleration.force-enabled" = lock-true;
				"accessibility.force_disabled" = 1;
				"browser.cache.memory.capacity" = 1024 * 1024; # 1024 MB
				"browser.cache.disk.enable" = false; # Force using memory

				# Responsivness Tweaks (Faster search, more aggressive preloading, etc)
				"network.http.max-persistent-connections-per-server" = 10;
				"network.http.max-connections" = 1024;
				"network.dns.disablePrefetch" = lock-false;
				"network.dns.disablePrefetchFromHTTPS" = lock-false; # Faster Pageload plugin
				"network.predictor.enabled" = lock-true;
				"network.predictor.enable-prefetch" = lock-true;
				"network.prefetch-next" = lock-true;
				"nglayout.initialpaint.delay" = 0;
				"nglayout.initialpaint.delay_in_oopif" = 0;
			};
		};
	};
}
