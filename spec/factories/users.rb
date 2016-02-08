FactoryGirl.define do
  factory :user, :class => User do |u|
    sequence(:email) { |n| "user#{n}@example.com" }
    password 'password'
  end
end

