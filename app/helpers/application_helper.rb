module ApplicationHelper

	def get_default_twitter_client

		client = Twitter::REST::Client.new do |config|
		  config.consumer_key        = "7LnFUoVNaCgu9x1qCxFpvXa8j"
		  config.consumer_secret     = "6dh16oa9q5KUBUhlT2mbV3YQ0E5JZJmvW5z63tFpyOYAmp5l2p"
		  config.access_token        = "2304850946-EMB8JHZVXeeSswSVHs1LjLGp6cABy05eH0IpAPD"
		  config.access_token_secret = "YXnOddRf1tu8OWeloVSIQzh7ZUCsiqhnYzsXE35G0tZbt"
		end
		return client
	end

	def rate_limited_followers (client, user, cursor)
	  	num_attempts = 0
	  	response = nil
		
		begin
			num_attempts += 1

			begin 
				response = client.followers(user, :cursor => cursor)	
			rescue Twitter::Error::Unauthorized => error
				Rails.logger.debug "$$$$$$$$$$$$$$$$$$$$ error raised for " + user + " in getting followers \n"
				return response
			end
		rescue Twitter::Error::TooManyRequests => error
			if num_attempts % 3 == 0
		  		sleep(15) # 15 sec
		  		retry
			else
		  		retry
			end
		end

		return response
	end

  	def rate_limited_twits (output_array, client, user)
	  	num_attempts = 0
		begin
			num_attempts += 1
			begin 
				output_array = output_array + client.user_timeline(user[:screen_name])
				
			rescue Twitter::Error::Unauthorized => error
				Rails.logger.debug "$$$$$$$$$$$$$$$$$$$$ error raised for " + user[:screen_name] + " in getting twits \n"
				return output_array
			end
		rescue Twitter::Error::TooManyRequests => error
			if num_attempts % 3 == 0
		  		sleep(30) # 30 seconds
		  		retry
			else
		  		retry
			end
		end
		return output_array
	end
end
