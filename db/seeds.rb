# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


music = Music.find_or_initialize_by(
  key: '142822858',
	provider: 'soundcloud',
)
music.title = 'DJ Kopec Mix #3.5'
music.artwork_url = "https://i1.sndcdn.com/artworks-000075433291-aruwbw-t500x500.jpg"
music.save!

comment = Comment.new
comment.body = 'いつもの部屋'
comment.save!(validate: false)
