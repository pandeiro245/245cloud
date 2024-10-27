# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
comment = Comment.find_or_initialize_by(id: 1)
comment.body = 'いつもの部屋'
comment.save(validate: false)


{
  '142822858' => {
    artwork_url: 'https://i1.sndcdn.com/artworks-000075433291-aruwbw-t500x500.jpg',
    title: 'DJ Kopec Mix #3.5'
  }
}.each do |key, hash|
  music = Music.find_or_initialize_by(
    key: key,
    provider: 'soundcloud',
  )
  music.artwork_url = hash[:artwork_url]
  music.title = hash[:title]
  music.save!
end
