shared_context 'base' do
  let!(:current_user) { create(:user, email: 'makarenkoj53@gmail.com', username: 'makarenkoj', first_name: 'Yura', last_name: 'Makarenko', password: 'Password123!') }

  def data
    return {} if response&.body.blank?

    JSON.parse(response.body)
  end
end
