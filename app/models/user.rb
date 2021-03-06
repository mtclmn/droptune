class User < ApplicationRecord
  has_many :follows, dependent:  :destroy
  has_many :artists, through: :follows
  has_many :albums, through: :artists
  has_many :music_videos, through: :artists
  has_many :news, through: :artists
  
  include Storext.model
  store_attributes :settings do
    show_compilations Boolean, default: false
    show_singles Boolean, default: true
  end

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: %i[twitter spotify]

  has_many :connections

  def to_param
    [id, screename.parameterize].join("-")
  end

  def screename
    if username.blank?
      Faker::FunnyName.name
    else
      username
    end
  end

  def fauxvatar
    seed = "#{id}#{email.to_s.gsub('-','')}".to_i
    topType = ['NoHair','Eyepatch','Hat','Hijab','Turban','LongHairBigHair','LongHairBob','LongHairBun','LongHairCurly','LongHairCurvy','LongHairDreads','LongHairFrida','LongHairFro','LongHairFroBand','LongHairNotTooLong','LongHairShavedSides','LongHairMiaWallace','LongHairStraight','LongHairStraight2','LongHairStraightStrand','ShortHairDreads01','ShortHairDreads02','ShortHairFrizzle','ShortHairShaggyMullet','ShortHairShortCurly','ShortHairShortFlat','ShortHairShortRound','ShortHairShortWaved','ShortHairSides','ShortHairTheCaesar','ShortHairTheCaesarSidePart','WinterHat1','WinterHat2','WinterHat3','WinterHat4']
    accessoriesType = ['Blank','Blank','Blank','Blank','Blank','Blank','Blank','Blank','Blank','Kurt','Prescription01','Prescription02','Round','Sunglasses','Wayfarers']
    hairColor = ['Auburn','Black','Blonde','BlondeGolden','Brown','BrownDark','PastelPink','Platinum','Red','SilverGray']
    hatColor = ['Black','Blue01','Blue02','Blue03','Gray01','Gray02','Heather','PastelBlue','PastelGreen','PastelOrange','PastelRed','PastelYellow','Pink','Red','White']
    facialHairType = ['Blank','BeardMedium','BeardLight','BeardMagestic','MoustacheFancy','MoustacheMagnum']
    facialHairColor = ['Auburn','Black','Blonde','BlondeGolden','Brown','BrownDark','Platinum','Red']
    clotheType = ['BlazerShirt','BlazerSweater','CollarSweater','GraphicShirt','Hoodie','Overall','ShirtCrewNeck','ShirtScoopNeck','ShirtVNeck']
    clotheColor = ['Black','Blue01','Blue02','Blue03','Gray01','Gray02','Heather','PastelBlue','PastelGreen','PastelOrange','PastelRed','PastelYellow','Pink','Red','White']
    graphicType = ['Bat','Cumbia','Deer','Diamond','Hola','Pizza','Resist','Selena','Bear','SkullOutline','Skull']
    eyeType = ['Close','Cry','Default','Dizzy','EyeRoll','Happy','Side','Squint','Surprised','Wink','WinkWacky']
    eyebrowType = ['Angry','AngryNatural','Default','DefaultNatural','FlatNatural','RaisedExcited','RaisedExcitedNatural','SadConcerned','SadConcernedNatural','UnibrowNatural','UpDown','UpDownNatural']
    mouthType = ['Concerned','Default','Disbelief','Eating','Grimace','Sad','ScreamOpen','Serious','Smile','Tongue','Twinkle']
    skinColor = ['Tanned','Yellow','Pale','Light','Brown','DarkBrown','Black']

    url = "?topType=#{topType.sample(random: Random.new(seed+1))}&accessoriesType=#{accessoriesType.sample(random: Random.new(seed+2))}&hairColor=#{hairColor.sample(random: Random.new(seed+3))}&facialHairType=#{facialHairType.sample(random: Random.new(seed+4))}&facialHairColor=#{facialHairColor.sample(random: Random.new(seed+5))}&clotheType=#{clotheType.sample(random: Random.new(seed+6))}&clotheColor=#{clotheColor.sample(random: Random.new(seed+7))}&graphicType=#{graphicType.sample(random: Random.new(seed+8))}&eyeType=#{eyeType.sample(random: Random.new(seed+9))}&eyebrowType=#{eyebrowType.sample(random: Random.new(seed+10))}&mouthType=#{mouthType.sample(random: Random.new(seed+11))}&skinColor=#{skinColor.sample(random: Random.new(seed+12))}&hatColor=#{hatColor.sample(random: Random.new(seed+12))}"
    "https://avataaars.io/#{url}"
  end

  def avatar_image
    if username
      "https://avatars.io/twitter/#{username}"
    else
      fauxvatar
    end
  end

  def self.create_from_provider_data(provider_data)
    user = User.find_or_initialize_by(provider: provider_data.provider, uid: provider_data.uid)

    user.email = provider_data.info.email
    user.username = provider_data.info.nickname
    user.name = provider_data.info.name
    user.avatar = provider_data.info.image
    user.password = Devise.friendly_token[0, 20]
    user.save 

    user
  end
end
