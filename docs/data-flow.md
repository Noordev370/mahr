# car data
 - ## in elm : 
 { 
    mark : String
    color : String
    modelDate : String
    price : String
    carPicture : Maybe File
    }

 - ## in http : MultiPart encoding of the same elm car model
 - ## in backend : encode the http to json and remove the carPicture field to be the file path on local file system
      and add status field initially set to 'availabil' to indicate it's availabil to be sold
 - ## in postgreSQL : will be in database schema
# user info
- ## in elm :
{ 
    username : String
    password : String
    confirmPassword : String
    bio : String
    profilePicture : Maybe File
    profilePictureAsBase64 : String
    }

- ## in http : MultiPart encoding of the same elm user model but with no profilePictureAsBase64 field 
- ## in backend : encode the http to json and remove the profilePicture field to be the file path on local file system
- ## in postgreSQL : will be in the database schema
