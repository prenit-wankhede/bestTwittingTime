class HomeController < ApplicationController
  include ApplicationHelper

  def index

  end

  def get_best_twit_time

  	if(!params[:username].blank? or !params[:user_id].blank?)

  		client = get_default_twitter_client # code moved to application helper module
		username_or_id = params[:username]
		username_or_id = params[:user_id] if username_or_id.blank?

		user = nil
		begin 
			user = client.user(username_or_id)
		rescue
			render plain: "User does not exist on twitter or you are not authorized" and return
		end

		followers = []
		next_cursor = -1

		while next_cursor != 0
			response = rate_limited_followers(client, username_or_id, next_cursor) # code moved to ApplicationHelper Module

			if(response.nil?)
				next_cursor = 0
			else
				followers = followers + response.attrs[:users]    
		    	next_cursor = response.attrs[:next_cursor]		
			end
			
		end

		twits_by_followers = []
		followers.each do |follower|
			response = rate_limited_twits(twits_by_followers, client, follower) # code moved to ApplicationHelper Module
			twits_by_followers = twits_by_followers + response
		end

		twit_time_slots = {}
		twit_day_slots = {}

		twits_by_followers.each do |twit|
			timestamp = twit.created_at
			twit_time_slots[timestamp.hour.to_s] = 0 if twit_time_slots[timestamp.hour.to_s].blank?
			twit_day_slots[timestamp.strftime('%A')] = 0 if twit_day_slots[timestamp.strftime('%A')].blank?
			twit_time_slots[timestamp.hour.to_s] = twit_time_slots[timestamp.hour.to_s] + 1
			twit_day_slots[timestamp.strftime('%A')] = twit_day_slots[timestamp.strftime('%A')] + 1
		end

		max_twit_time_slot = twit_time_slots.max_by{|k,v| v}
		max_twit_day_slot = twit_day_slots.max_by{|k,v| v}
		
		render plain: username_or_id + " should twit between " + max_twit_time_slot[0] + ":00 to " + (max_twit_time_slot[0].to_i + 1).to_s + ":00 and on " + max_twit_day_slot[0]

  	else
  		render :index	
  	end
  	
	  	
  end
end
