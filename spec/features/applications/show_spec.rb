require 'rails_helper'

RSpec.describe 'application show page' do

  it 'displays applicant name, address(street, city, state, zip), description and status ' do

    application_1 = Application.create!(name:'Alice', street: '357 test st', city: 'Frederickburg', state: 'VA', zip: '22406', description: "I am great")

    visit "/applications/#{application_1.id}"
    within("#application-#{application_1.id}") do
      expect(page).to have_content(application_1.name)
      expect(page).to have_content(application_1.street)
      expect(page).to have_content(application_1.city)
      expect(page).to have_content(application_1.state)
      expect(page).to have_content(application_1.zip)
      expect(page).to have_content(application_1.description)
      expect(page).to have_content(application_1.status)
    end
  end

  it 'if application is In Progress, show a search field to find a pet by name' do
    application_1 = Application.create!(name:'Alice', street: '357 test st', city: 'Frederickburg', state: 'VA', zip: '22406', description: "I am great")
    visit "/applications/#{application_1.id}"
    within("#add_pet-#{application_1.id}") do
      expect(page).to have_content("Add a Pet to this Application")
      expect(find('form')).to have_content('Enter Pet Name')
    end
  end

  it 'after searching for pet names, a list of matching names are returned (case insensative, partial matches accepted)' do
    application_1 = Application.create!(name:'Alice', street: '357 test st', city: 'Frederickburg', state: 'VA', zip: '22406', description: "I am great")
    shelter = Shelter.create(name: 'Aurora shelter', city: 'Aurora, CO', foster_program: false, rank: 9)
    pet_1 = Pet.create(adoptable: true, age: 1, breed: 'sphynx', name: 'Lucille Bald', shelter_id: shelter.id)
    pet_2 = Pet.create(adoptable: true, age: 3, breed: 'doberman', name: 'Lobster', shelter_id: shelter.id)
    pet_3 = Pet.create(adoptable: false, age: 2, breed: 'saint bernard', name: 'Beethoven', shelter_id: shelter.id)
    visit "/applications/#{application_1.id}"
    fill_in('Enter Pet Name:', with: 'LuCiLl')
    click_button 'Search'
    expect(page).to have_content(pet_1.name)
  end

  it "pet names are links to that pet's id page" do

    shelter_1 = Shelter.create(name: 'Aurora shelter', city: 'Aurora, CO', foster_program: false, rank: 9)
    pet_1 = shelter_1.pets.create(name: 'Mr. Pirate', breed: 'tuxedo shorthair', age: 5, adoptable: true)
    pet_2 = shelter_1.pets.create(name: 'Clawdia', breed: 'shorthair', age: 3, adoptable: true)
    pet_3 = shelter_1.pets.create(name: 'Lucille Bald', breed: 'sphynx', age: 8, adoptable: true)
    application_1 = Application.create!(name:'Alice', street: '357 test st', city: 'Frederickburg', state: 'VA', zip: '22406', description: "I am great")
    PetApplication.create!(pet: pet_1, application: application_1)

    visit "/applications/#{application_1.id}"
    within("#application-#{application_1.id}") do
      click_link "#{pet_1.name}"
      expect(current_path).to eq("/pets/#{pet_1.id}")
    end
  end

  it 'has a button to "Adopt this Pet" that adds pet to application' do

    application_1 = Application.create!(name:'Alice', street: '357 test st', city: 'Frederickburg', state: 'VA', zip: '22406', description: "I am great")
    shelter = Shelter.create(name: 'Aurora shelter', city: 'Aurora, CO', foster_program: false, rank: 9)
    pet_1 = Pet.create(adoptable: true, age: 1, breed: 'sphynx', name: 'Lucille Bald', shelter_id: shelter.id)
    pet_2 = Pet.create(adoptable: true, age: 3, breed: 'doberman', name: 'Lobster', shelter_id: shelter.id)
    pet_3 = Pet.create(adoptable: false, age: 2, breed: 'saint bernard', name: 'Beethoven', shelter_id: shelter.id)

    visit "/applications/#{application_1.id}"
    fill_in('Enter Pet Name:', with: 'LuCiLl')
    click_button 'Search'
    expect(page).to have_content(pet_1.name)
    expect(page).to have_button("Adopt this Pet")
    click_button("Adopt this Pet")
    expect(page).to have_content("Pets: #{pet_1.name}")
  end
end
