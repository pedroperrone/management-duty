I18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')]
 
# Whitelist locales available for the application
I18n.available_locales = [:en, :pt]
 
# Set default locale to something other than :en
I18n.default_locale = :pt
