module RailsAdmin
  module Config
    module Actions
      class Dashboard < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)
	
	require "ibm_watson/authenticators"
	require "ibm_watson/text_to_speech_v1"
	include IBMWatson
        register_instance_option :root? do
          true
        end

        register_instance_option :breadcrumb_parent do
          nil
        end

        register_instance_option :controller do
          proc do
		#if current_user.admin == true
			authenticator = Authenticators::IamAuthenticator.new(
				apikey: ENV['WATSON']
			)
		
			text_to_speech = IBMWatson::TextToSpeechV1.new(
				authenticator: authenticator
			)
			text_to_speech.service_url = ENV['WATSON_URL']
			employee = Employee.find_by(user_id: current_user.id)
			File.open("app/assets/audios/audio.mp3", "wb") do |audio_file|
				response = text_to_speech.synthesize(
					text: "Hello #{employee.firstName} #{employee.lastName}. There are currently #{Elevator.count} elevators deployed in the #{Building.count} buildings of your #{Customer.count} customers.Currently, #{Elevator.where(status: 1).count} elevators are not in Running Status and are being serviced. You currently have #{Quote.where(status: true).count} quotes awaiting processing.You currently have #{Lead.count} leads in your contact requests. #{Battery.count} Batteries are deployed across #{Address.pluck(:city).uniq.count} cities
					",
					accept: "audio/mp3",
					voice: "en-US_AllisonVoice"
				).result
			audio_file.write(response)
			end
			
			data = File.read("lib/star_wars.json")
			json= JSON.parse(data)
			
			File.open("app/assets/audios/star_wars.mp3", "wb") do |audio_file|
				response = text_to_speech.synthesize(
					text: json[current_user.star_wars],
					accept: "audio/mp3",
					voice: "en-US_AllisonVoice"
				).result
			audio_file.write(response)
			end
		#end
		
		@listmap = []
		
		Building.find_each do |b|
			address = b.address
			batt = b.battery.count
            b_ids = Battery.where(building_id: b.id).ids
            c = Column.where(battery_id: b_ids).count
            c_ids = Column.where(battery_id: b_ids).ids
            e = Elevator.where(column_id: c_ids).count
			floorsSum = 0
			Column.where(battery_id: b_ids).each do |cc|
				floorsSum += cc.numberFloor
			end
			@listmap << {name: b.fullName,
					zipCode: address.postalCode,
                    lat: address.lat, long: address.long, 
                    address: address.street,
					floors: floorsSum,
                    client: b.fullName, 
                    battery: batt, column: c, elevator: e,
                    technician: b.techName}
		end
		
            #After you're done processing everything, render the new dashboard
            render @action.template_name, status: 200
          end
        end

        register_instance_option :route_fragment do
          ''
        end

        register_instance_option :link_icon do
          'icon-home'
        end

        register_instance_option :statistics? do
          true
        end
      end
    end
  end
end