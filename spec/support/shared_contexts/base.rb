shared_context 'base' do
  let!(:current_user) { create(:user, email: 'makarenkoj53@gmail.com', username: 'makarenkoj', first_name: 'Yura', password: 'Password123!') }
  let(:locale) { I18n.locale }

  def data
    return {} if response&.body.blank?

    JSON.parse(response.body)
  end
end
