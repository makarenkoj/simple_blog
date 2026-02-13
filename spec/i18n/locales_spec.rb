require 'rails_helper'

RSpec.describe 'I18n locales (simple)' do
  LOCALES = [:en, :uk, :it].freeze

  describe 'basic setup' do
    it 'has all required locale files' do
      LOCALES.each do |locale|
        file = Rails.root.join('config', 'locales', "#{locale}", "#{locale}.yml")
        expect(File.exist?(file)).to be(true), "Missing #{locale}.yml"
      end
    end

    it 'can load all locales without errors' do
      LOCALES.each do |locale|
        expect { I18n.t('hello', locale: locale) }.not_to raise_error
      end
    end
  end

  describe 'critical translations exist' do
    critical_keys = ['hello',
                     'follow',
                     'followers',
                     'activerecord.attributes.user.email',
                     'activerecord.attributes.user.password',
                     'activerecord.attributes.posts.title',
                     'activerecord.controllers.posts.created',
                     'activerecord.controllers.posts.not_found',
                     'notifications.new_post',
                     'search.search',
                     'errors.messages.blank',
                     'date.formats.default'
                    ]

    LOCALES.each do |locale|
      context "#{locale} locale" do
        critical_keys.each do |key|
          it "has translation for '#{key}'" do
            translation = I18n.t(key, locale: locale, default: :__missing__)
            expect(translation).not_to eq(:__missing__), "Missing #{locale}.#{key}"
          end
        end
      end
    end
  end

  describe 'no missing interpolations' do
    interpolated_keys = { 'notifications.new_post' => [:author, :title],
                          'notifications.new_follower' => [:follower],
                          'search.found_results' => [:count]
                        }

    LOCALES.each do |locale|
      context "#{locale} locale" do
        interpolated_keys.each do |key, variables|
          it "has all variables in '#{key}'" do
            translation = I18n.t(key, locale: locale)

            variables.each do |var|
              expect(translation).to include("%{#{var}}"), "#{locale}.#{key} missing %{#{var}}"
            end
          end
        end
      end
    end
  end

  describe 'pluralization works' do
    LOCALES.each do |locale|
      it "#{locale} can pluralize" do
        one = I18n.t('datetime.distance_in_words.x_days', count: 1, locale: locale)
        many = I18n.t('datetime.distance_in_words.x_days', count: 5, locale: locale)

        expect(one).to be_present
        expect(many).to be_present
        expect(one).not_to eq(many) unless locale == :it
      end
    end
  end

  describe 'no empty translations' do
    LOCALES.each do |locale|
      it "#{locale} has no obviously empty strings" do
        empty = []

        I18n.backend.send(:translations)[locale].each do |key, value|
          empty << key if value.is_a?(String) && value.strip.empty?
        end

        expect(empty).to be_empty, "Empty translations in #{locale}: #{empty.join(', ')}"
      end
    end
  end
end
