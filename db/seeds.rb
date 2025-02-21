# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# create a seed for the clint "default"
# message: Seeding started
puts "Seeding started"

# destroy all clients
Client.destroy_all

# destroy all users
User.destroy_all

#create a client "default"
client = Client.find_or_create_by!(name: "default")

# create a seed for the user "admin"
User.find_or_create_by!(email: "bluemystic48@gmail.com") do |user|
  user.first_name = "admin"
  user.last_name = "admin"
  user.password = "password"
  user.password_confirmation = "password"
  user.role = "admin"
  user
end

# create a seed for the user "manager"
User.find_or_create_by!(email: "florian.sitte@live.de") do |user|
  user.first_name = "Florian"
  user.last_name = "Sitte"
  user.password = "password"
  user.password_confirmation = "password"
  user.role = "manager"
  user
end

# create a seed for the user "employee"
User.find_or_create_by!(email: "bluemystic48@gmail.com") do |user|
  user.first_name = "Em"
  user.last_name = "Ployee"
  user.password = "password"
  user.password_confirmation = "password"
  user.role = "employee"
  user
end

# terminal message: Seeding completed
puts "Seeding completed"
