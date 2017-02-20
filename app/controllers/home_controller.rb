class HomeController < ApplicationController
  def index

  end

  def get_best_twit_time

  	if(!params[:username].blank? or !params[:user_id].blank?)

  		client = Twitter::REST::Client.new do |config|
		  config.consumer_key        = "7LnFUoVNaCgu9x1qCxFpvXa8j"
		  config.consumer_secret     = "6dh16oa9q5KUBUhlT2mbV3YQ0E5JZJmvW5z63tFpyOYAmp5l2p"
		  config.access_token        = "2304850946-EMB8JHZVXeeSswSVHs1LjLGp6cABy05eH0IpAPD"
		  config.access_token_secret = "YXnOddRf1tu8OWeloVSIQzh7ZUCsiqhnYzsXE35G0tZbt"
		end

		#me = client.user("prenitwankhede")

		username_or_id = params[:username]
		username_or_id = params[:user_id] if !username_or_id.blank?

		followers = []
		next_cursor = -1

		while next_cursor != 0
			response = client.followers(username_or_id, :cursor => next_cursor)
			followers = followers + response.attrs[:users]    
		    next_cursor = response.attrs[:next_cursor]
		end

		twits_by_followers = []
		followers.each do |follower|
			begin 
				twits_by_followers = twits_by_followers + client.user_timeline(follower[:screen_name])
			rescue
				Rails.logger.debug "$$$$$$$$$$$$$$$$$$$$ error raised for " + follower[:screen_name] + "\n"
			end
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

		render plain: username_or_id + " should twit between " + max_twit_time_slot[0] + " to " + (max_twit_time_slot[0].to_i + 1).to_s + " and on " + max_twit_day_slot[0]
  	else
  		render :index	
  	end
  	
  	
  end
end
