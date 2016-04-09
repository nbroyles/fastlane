# rubocop:disable Style/IndentationConsistency
# We disable this rule since we intend opening HTML labels
module Danger
  class Dangerfile
    module DSL
      # A danger plugin: https://github.com/danger/danger
      class DeviceGrid < Plugin
        # @param languages: Array of languages you want to see (e.g. [en, de])
        # @param devices: Array of deviecs you want to see (e.g. ["iphone4s", "ipadair"])
        # @param prefix_command: Prefix the `fastlane run appetize_url_generator` command with something
        #   this can be used to use `bundle exec`
        def run(languages: nil, devices: nil, prefix_command: nil)
          public_key_path = "fastlane/appetize_public_key.txt"
          public_key = File.read(public_key_path).strip if File.exist?(public_key_path)
          UI.user_error!("No #{public_key_path} file found, make sure to run fastlane with `generate_device_grid` before calling `device_grid` in danger") if public_key.to_s.length == 0
          File.delete(public_key_path)

          devices ||= %w(iphone4s iphone5s iphone6s iphone6splus ipadair)
          languages ||= ["en"]
          prefix_command ||= ""

          deep_link_matches = pr_body.match(/:link:\s(.*)/) # :link: emoji
          deep_link = deep_link_matches[1] if deep_link_matches

          ENV["FASTLANE_DISABLE_COLORS"] = "true" # since we fetch the URL from the output

          markdown("<table>")
          languages.each do |current_language|
            markdown("<tr>")
              markdown("<td>")
                markdown("<b>#{current_language[0..1]}</b>")
              markdown("</td>")

              devices.each do |current_device|
                markdown("<td>")

                params = {
                  public_key: public_key,
                  language: current_language,
                  device: current_device
                }
                params[:launch_url] = deep_link if deep_link
                params_str = params.collect { |k, v| "#{k}:\"#{v}\"" }.join(" ")
                url = `#{prefix_command} fastlane run appetize_url_generator #{params_str}`
                url = url.match(%r{Result:.*(https\:\/\/.*)})[1].strip

                markdown("<a href='#{url}'>")
                  markdown("<img src='#{url_for_device(current_device)}' />")
                  markdown("<p align='center'>#{beautiful_device_name(current_device)}</p>")
                markdown("</a>")

                markdown("</td>")
              end
            markdown("</tr>")
          end
          markdown("</table>")
        end

        def beautiful_device_name(str)
          str = str.to_sym
          return {
            iphone4s: "iPhone 4s",
            iphone5s: "iPhone 5s",
            iphone6s: "iPhone 6s",
            iphone6splus: "iPhone 6s Plus",
            ipadair: "iPad Air",
            iphone6: "iPhone 6",
            iphone6plus: "iPhone 6 Plus",
            ipadair2: "iPad Air 2",
            nexus5: "Nexus 5",
            nexus7: "Nexus 7",
            nexus9: "Nexus 9"
          }[str] || str.to_s
        end

        def url_for_device(str)
          str = str.to_sym
          return {
            iphone4s: "http://mockuphone.com/static/images/phones/iphone5s_spacegrey_portrait.png",
            iphone5s: "http://mockuphone.com/static/images/phones/iphone5s_spacegrey_portrait.png",
            iphone6s: "http://mockuphone.com/static/images/phones/iphone6/iphone6_spacegrey_portrait.png",
            iphone6splus: "http://mockuphone.com/static/images/phones/iphone6plus/iphone6plus_spacegrey_portrait.png",
            ipadair: "http://mockuphone.com/static/images/phones/ipadair2/ipadair2_spacegrey_portrait.png"
          }[str] || ""
        end

        def self.description
          [
            "Render a grid of devices"
          ].join(" ")
        end
      end
    end
  end
end
# rubocop:enable Style/IndentationConsistency
