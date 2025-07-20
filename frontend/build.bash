# do clean build
rm -r ./static
mkdir static
mkdir ./static/elm
mkdir ./static/html
mkdir ./static/css
mkdir ./static/images

# build elm
cd elm
elm make src/SignIn.elm --output=../static/elm/sign-in.js
elm make src/SignUp.elm --output=../static/elm/sign-up.js
elm make src/Profile.elm --output=../static/elm/profile.js
elm make src/PostCar.elm --output=../static/elm/post-car.js
elm make src/SearchCars.elm --output=../static/elm/search-cars.js
cd ..

# copy html files
cp -r ./html/* ./static/html

# build css
cp -r ./css/* ./static/css

# copy images
cp -r ./images/* ./static/images

# then copy the static folder to backend
rm -r ../backend/static
cp -r ./static ../backend
