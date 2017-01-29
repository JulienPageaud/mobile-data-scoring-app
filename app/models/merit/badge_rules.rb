# Be sure to restart your server when you modify this file.
#
# +grant_on+ accepts:
# * Nothing (always grants)
# * A block which evaluates to boolean (recieves the object as parameter)
# * A block with a hash composed of methods to run on the target object with
#   expected values (+votes: 5+ for instance).
#
# +grant_on+ can have a +:to+ method name, which called over the target object
# should retrieve the object to badge (could be +:user+, +:self+, +:follower+,
# etc). If it's not defined merit will apply the badge to the user who
# triggered the action (:action_user by default). If it's :itself, it badges
# the created object (new user for instance).
#
# The :temporary option indicates that if the condition doesn't hold but the
# badge is granted, then it's removed. It's false by default (badges are kept
# forever).

module Merit
  class BadgeRules
    include Merit::BadgeRulesMethods

    def initialize
      # If it creates user, grant badge
      # Should be "current_user" after registration for badge to be granted.
      # Find badge by badge_id, badge_id takes presidence over badge
      # grant_on 'users#create', badge_id: 7, badge: 'just-registered', to: :itself

      # If it has 10 comments, grant commenter-10 badge
      # grant_on 'comments#create', badge: 'commenter', level: 10 do |comment|
      #   comment.user.comments.count == 10
      # end

      # If it has 5 votes, grant relevant-commenter badge
      # grant_on 'comments#vote', badge: 'relevant-commenter',
      #   to: :user do |comment|
      #
      #   comment.votes.count == 5
      # end

      # Changes his name by one wider than 4 chars (arbitrary ruby code case)
      # grant_on 'registrations#update', badge: 'autobiographer',
      #   temporary: true, model_name: 'User' do |user|
      #
      #   user.name.length > 4
      # end

      # Iron medal granted to all new users
      grant_on 'registrations#create', badge: 'iron-medal', model_name: 'User'

      #TO DO - When the fb connect/psycometric tests are implemented
      # add the controller action which handles those to grant_on's
      #TO DO - When the repayment functionality is added
      # add the controller action which handles that to grant_on's

      # Bronze medal granted on one repaid loan OR FB connect + psychometric test
      grant_on ['users#status', 'users#profile', 'users#show'], badge: 'bronze-medal', temporary: true do |user|
        user.loans.any? { |loan| loan.status == "Loan Repaid" } &&
        user.loans.none? { |loan| loan.any_missed_payment? }
      end
      # Silver medal granted on two repaid loans OR FB connect + psychometric tests + one repaid loan
      grant_on ['users#status', 'users#profile', 'users#show'], badge: 'silver-medal', temporary: true do |user|
        (user.loans.count { |loan| loan.status == "Loan Repaid" } >= 2) &&
        user.loans.none? { |loan| loan.any_missed_payment? }
      end
      # Gold medal granted on three repaid loans OR FB connect + psychometric test + two repaid loans
      grant_on ['users#status', 'users#profile', 'users#show'], badge: 'gold-medal', temporary: true do |user|
        (user.loans.count { |loan| loan.status == "Loan Repaid" } >= 3) &&
        user.loans.none? { |loan| loan.any_missed_payment? }
      end
    end
  end
end
