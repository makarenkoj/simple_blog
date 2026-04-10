module Avo
  module Actions
    class GenerateApiToken < Avo::BaseAction
      self.name = 'Згенерувати API Токен'
      self.message = 'Оберіть термін дії токена. Увага: якщо у юзера вже є токен, старий буде анульовано!'
      self.confirm_button_label = 'Згенерувати'

      def fields
        field :expiration, as: :select, name: 'Термін дії', options: {
          'Безстроково' => 'never',
          '1 Тиждень' => '1_week',
          '1 Місяць' => '1_month'
        }, default: 'never'
      end

      def handle(**args)
        fields = args[:fields]
        users = args[:query] || [args[:record]].compact

        users.each do |user|
          expires_in = case fields[:expiration]
                       when '1_week'  then 1.week
                       when '1_month' then 1.month
                       end

          ApiTokenService.generate!(user, expires_in: expires_in)
        end

        succeed 'API Токен успішно згенеровано! Оновіть сторінку, щоб побачити його.'
      end
    end
  end
end
