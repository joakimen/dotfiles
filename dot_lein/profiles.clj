{:user {:plugins [[lein-ancient "1.0.0-RC3"]]
        :dependencies [[pjstadig/humane-test-output "0.11.0"]]
        :injections [(require 'pjstadig.humane-test-output)
                     (pjstadig.humane-test-output/activate!)]}}

