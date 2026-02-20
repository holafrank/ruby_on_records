# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

Sale.destroy_all
Disk.destroy_all
Genre.destroy_all

# === Géneros Musicales === #

genres = [
  "R&B", "Pop", "Soul", "Funk", "Indie rock", "Rock", "Rock progresivo", "Folklore","Psicodelico", "Rock argentino", "Rock alternativo",
  "K-pop", "Pop rock", "Jazz", "Tango", "Electrónica", "Música clásica", "Samba", "Trap", "Hip-Hop", "Ópera"
]

genres.each do |genre_name|
  Genre.find_or_create_by!(genre_name: genre_name)
end

# === Discos === #

disk = Disk.new(title: "Miracles",
year: 1972,
description: "Miracles es el séptimo y último álbum de estudio como solista de la cantante peruana Yma Sumac. Su canto se inspiró en el canto de las aves peruanas y su música se caracterizó por la fusión musical. Sumac interpretó su propia versión lírica del reconocido «El cóndor pasa» en este álbum.",
artist: "Yma Sumac",
price: 250_000,
stock: 1,
format: "Vinilo",
state: "Usado")
disk.genres << Genre.find_or_create_by!(genre_name: "Psicodelico")
disk.genres << Genre.find_or_create_by!(genre_name: "Rock")
disk.genres << Genre.find_or_create_by!(genre_name: "Folklore")
disk.genres << Genre.find_or_create_by!(genre_name: "Ópera")
disk.cover.attach(
  io: File.open(Rails.root.join("app/assets/images/miracles.jpg")),
  filename: "miracles.jpeg",
  content_type: "image/jpeg"
)
disk.audio_sample.attach(
  io: File.open(Rails.root.join("app/assets/audios/el-condor-pasa.mp3")),
  filename: "el-condor-pasa.mp3",
  content_type: "audio/mpeg"
)
disk.save!

disk = Disk.new(title: "Diamonds and Pearls",
year: 1991,
description: "Este fue el segundo trabajo de Prince en ser lanzado oficialmente junto a The New Power Generation. Diamonds and Pearls presenta una fusión de estilos musicales, desde el funk y el soul hasta el rock y baladas.",
artist: "The New Power Generation",
price: 25_000,
stock: 100,
format: "CD",
state: "Nuevo")
disk.genres << Genre.find_or_create_by!(genre_name: "Pop")
disk.genres << Genre.find_or_create_by!(genre_name: "R&B")
disk.genres << Genre.find_or_create_by!(genre_name: "Soul")
disk.genres << Genre.find_or_create_by!(genre_name: "Funk")
disk.cover.attach(
  io: File.open(Rails.root.join("app/assets/images/diamonds-and-pearls.jpg")),
  filename: "diamonds-and-pearls.jpg",
  content_type: "image/jpeg"
)
disk.save!

disk = Disk.new(title: "I Got Dem Ol' Kozmic Blues Again Mama!",
year: 1969,
description: "El primer álbum en solitario de Janis Joplin fue un movimiento muy arriesgado. Había conseguido el éxito comercial y crítico con 'Cheap Thrills' y ahora la Bruja Cósmica se alejaba de los sonidos ácidos y psicodélicos de su anterior banda -Big Brother & The Holding Company- y se adentraba en pasajes más propios del Soul y el Blues.",
artist: "Janis Joplin",
price: 20_000,
stock: 50,
format: "CD",
state: "Nuevo")
disk.genres << Genre.find_or_create_by!(genre_name: "Blues")
disk.genres << Genre.find_or_create_by!(genre_name: "Rock")
disk.genres << Genre.find_or_create_by!(genre_name: "Soul")
disk.cover.attach(
  io: File.open(Rails.root.join("app/assets/images/i-got-dem-ol-kozmic-blues-again-mama.jpg")),
  filename: "i-got-dem-ol-kozmic-blues-again-mama.jpg",
  content_type: "image/jpeg"
)
disk.save!

disk = Disk.new(title: "The Red",
year: 2015,
description: "The Red es el primer álbum de estudio del grupo femenino surcoreano Red Velvet. El concepto del álbum se centra únicamente en la imagen «Red» del grupo, donde muestran su imagen vívida y osada.",
artist: "Red Velvet",
price: 35_000,
stock: 200,
format: "CD",
state: "Nuevo")
disk.genres << Genre.find_or_create_by!(genre_name: "Pop")
disk.genres << Genre.find_or_create_by!(genre_name: "K-pop")
disk.genres << Genre.find_or_create_by!(genre_name: "R&B")
disk.genres << Genre.find_or_create_by!(genre_name: "Funk")
disk.cover.attach(
  io: File.open(Rails.root.join("app/assets/images/the-red.png")),
  filename: "the-red.png",
  content_type: "image/png"
)
disk.save!

disk = Disk.new(title: "Yours Truly, Angry Mob",
year: 2007,
description: "El lanzamiento de este álbum estuvo precedido por el lanzamiento de Ruby, el primer sencillo del álbum. Al igual que el álbum debut de la banda, Employment, Yours Truly, Angry Mob fue producido, una vez más por Stephen Street, siendo este disco, con respecto a las letras, más oscuro y con más conciencia social que el anterior, con canciones que tratan de temas tales como los crímenes, la violencia y la fama.",
artist: "Kaiser Chiefs",
price: 15_000,
stock: 50,
format: "CD",
state: "Nuevo")
disk.genres << Genre.find_or_create_by!(genre_name: "Indie")
disk.genres << Genre.find_or_create_by!(genre_name: "Rock")
disk.genres << Genre.find_or_create_by!(genre_name: "Rock alternativo")
disk.cover.attach(
  io: File.open(Rails.root.join("app/assets/images/yours-truly-angry-mob.jpeg")),
  filename: "yours-truly-angry-mob.jpeg",
  content_type: "image/jpeg"
)
disk.save!

disk = Disk.new(title: "Wish You Were Here",
year: 1975,
description: "Los temas líricos del álbum se refieren a la alienación y la crítica del negocio de la música. La mayor parte del álbum está ocupada por «Shine On You Crazy Diamond», un tributo de nueve partes al miembro fundador Syd Barrett, quien dejó la banda siete años antes debido al deterioro de su salud mental.",
artist: "Pink Floyd",
price: 170_000,
stock: 1,
format: "Vinilo",
state: "Usado")
disk.genres << Genre.find_or_create_by!(genre_name: "Rock progresivo")
disk.genres << Genre.find_or_create_by!(genre_name: "Rock")
disk.genres << Genre.find_or_create_by!(genre_name: "Psicodelico")
disk.cover.attach(
  io: File.open(Rails.root.join("app/assets/images/wish-you-were-here.jpg")),
  filename: "wish-you-were-here.jpg",
  content_type: "image/jpeg"
)
disk.audio_sample.attach(
  io: File.open(Rails.root.join("app/assets/audios/have-a-cigar.mp3")),
  filename: "have-a-cigar.mp3",
  content_type: "audio/mpeg"
)
disk.save!

disk = Disk.new(title: "Jessico",
year: 2001,
description: "Jessico es el sexto álbum de estudio de la banda argentina Babasónicos. El disco significó para la banda la entrada a la lista de los grupos más importantes de la Argentina, en el momento donde había ocurrido una crisis en diciembre de 2001 en el país. Jessico está considerado como el #16 entre los 100 mejores álbumes del rock argentino según la lista de la revista Rolling Stone.",
artist: "Babasónicos",
price: 20_000,
stock: 200,
format: "CD",
state: "Nuevo")
disk.genres << Genre.find_or_create_by!(genre_name: "Rock argentino")
disk.genres << Genre.find_or_create_by!(genre_name: "Rock")
disk.genres << Genre.find_or_create_by!(genre_name: "Psicodelico")
disk.genres << Genre.find_or_create_by!(genre_name: "Pop rock")
disk.genres << Genre.find_or_create_by!(genre_name: "Pop")
disk.cover.attach(
  io: File.open(Rails.root.join("app/assets/images/jessico.jpg")),
  filename: "jessico.jpg",
  content_type: "image/jpeg"
)
disk.save!

disk = Disk.new(title: "Alma de Diamante",
year: 1980,
description: "El disco está integrado por siete temas compuestos por Spinetta bajo la inspiración de sus lecturas de cuatro libros relacionados con el chamanismo, del antropólogo Carlos Castaneda: Las enseñanzas de Don Juan, Una realidad aparte, Viaje a Ixtlán y Relatos de poder.",
artist: "Spinetta Jade",
price: 150_000,
stock: 1,
format: "CD",
state: "Usado")
disk.genres << Genre.find_or_create_by!(genre_name: "Rock argentino")
disk.genres << Genre.find_or_create_by!(genre_name: "Rock")
disk.genres << Genre.find_or_create_by!(genre_name: "Jazz")
disk.genres << Genre.find_or_create_by!(genre_name: "Rock progresivo")
disk.cover.attach(
  io: File.open(Rails.root.join("app/assets/images/alma-de-diamante.jpeg")),
  filename: "alma-de-diamante.jpeg",
  content_type: "image/jpeg"
)
disk.save!


disk = Disk.new(title: "Amapola del 66",
year: 2010,
description: "Por Nehuén Gusmerotti: 'Los temas de este disco están plagados de historias. Historias colectadas por la banda en años de caminos, de recitales, de viajes por todo nuestro país. Tuvo en su génesis la llegada de los nuevos tiempos y la reivindicación de un pasado de sueños y de ingenuidad(...). En este verdadero himno zeppeliano la banda vuelve a sus orígenes, a la ingenuidad y frescura de un movimiento naciente como era nuestro rock en esos años.'",
artist: "Divididos",
price: 35_000,
stock: 200,
format: "CD",
state: "Nuevo")
disk.genres << Genre.find_or_create_by!(genre_name: "Rock argentino")
disk.genres << Genre.find_or_create_by!(genre_name: "Rock")
disk.genres << Genre.find_or_create_by!(genre_name: "Folklore")
disk.genres << Genre.find_or_create_by!(genre_name: "Chacarera")
disk.cover.attach(
  io: File.open(Rails.root.join("app/assets/images/amapola-del-66.jpeg")),
  filename: "amapola-del-66.jpeg",
  content_type: "image/jpeg"
)
disk.save!

# === Usuarios === #

User.destroy_all

# Admin
User.create!(
  full_name: "Nicolas Admin",
  email: "admin@rubyonrecords.com",
  password: "admin123",
  password_confirmation: "admin123",
  role: :admin
)

# Gerente
User.create!(
  full_name: "Maria Gerente",
  email: "gerente@rubyonrecords.com",
  password: "gerente123",
  password_confirmation: "gerente123",
  role: :manager
)

# Empleado
User.create!(
  full_name: "Juan Empleado",
  email: "empleado@rubyonrecords.com",
  password: "empleado123",
  password_confirmation: "empleado123",
  role: :employee
)

# === Clientes === #

Client.destroy_all

Client.create!(
  name: "Chaka",
  contact: "feel4u@mail.com"
)

Client.create!(
  name: "Wallas",
  contact: "guillermocidade@wallas.com"
)

Client.create!(
  name: "Mr. Pink",
  contact: "pink_float@mail.com"
)

p "* * * * * * * * * * * * * * * "
p "* * * #{Genre.count} géneros creados * * *"
p "* * * #{Disk.count} discos creados * * *"
p "* * * #{User.count} usuarios creados * * *"
p "* * * #{Client.count} clientes creados * * *"
p "* * * * * * * * * * * * * * * "
