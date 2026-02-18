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
				"browser.urlbar.suggest.trending" = lock-false;
				"browser.urlbar.suggest.weather" = lock-false;
				"browser.urlbar.suggest.addons" = lock-false;
				"browser.urlbar.suggest.calculator" = lock-false;
				"browser.urlbar.suggest.clipboard" = lock-false;
				"browser.urlbar.suggest.engines" = lock-false;
				"browser.urlbar.suggest.fakespot" = lock-false;
				"browser.urlbar.suggest.pocket" = lock-false;

				# Tab Groups
				"browser.tabs.groups.enabled" = lock-true;
			};
		};
	};
}
