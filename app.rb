require "sinatra"
require "csv"
require "sinatra/reloader" if development?

current_dir = Dir.pwd
Dir["#{current_dir}/models/*.rb"].each { |file| require file }

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  def self.run!
    if not Observation.any?
      csv = "covid_19_data.csv"
      observations = []
      CSV.foreach(csv, headers: true) do |row|
        date = Date.strptime(row["ObservationDate"], '%m/%d/%Y')

        # There are different date formats for "Last Update" column
        # sample formats:
        #   4/6/20 9:37
        #   1/22/2020 17:00
        #   2020-04-07 23:11:31
        #   2020-01-31T08:15:53
        #
        # Check if string date includes slash then do strptime
        # else do straight forward date parsing
        if row["Last Update"].include? '/'
          update = DateTime.strptime(row["Last Update"], '%m/%d/%Y %H:%M')
        else
          update = DateTime.parse(row["Last Update"]).to_datetime
        end

        # Collect all the observations and put in an array
        # then use activerecord insert_all for faster transaction
        observations.push(
          {
            sno: row["SNo"],
            observation_date: date,
            province: row["Province/State"],
            country: row["Country/Region"],
            last_update: update,
            confirmed: row["Confirmed"],
            deaths: row["Deaths"],
            recovered: row["Recovered"]
          }
        )
      end
      Observation.insert_all(observations)
    end
    super
  end

  before do
    @observation_date =  Date.parse(params[:observation_date]) rescue false
    @max_results = params[:max_results].to_i

    # return 422 if observation_date is missing or incorrect date format
    if not @observation_date
      halt 422, 
        {"Content-Type" => "application/json"},
        {error: "Incorrect/missing observation_date parameter"}.to_json
    end
  end

  get "/top/confirmed" do
    content_type :json
    {
      observation_date: params[:observation_date],
      countries: observation_list
    }.to_json
  end

  def observation_list
    countries = []
    # Group by country
    # Filter by observation_date
    # SUM confirmed, deaths, recovered
    # order by confirmed cases descending
    # top results
    observations = Observation
      .group(:country)
      .select(:country, "SUM(confirmed) as confirmed, SUM(deaths) as deaths, SUM(recovered) as recovered")
      .where(observation_date: @observation_date)
      .order("confirmed desc")
      .first(@max_results)
    observations.each do |observation|
      countries.push(
        {
          country: observation[:country],
          confirmed: observation[:confirmed],
          deaths: observation[:deaths],
          recovered: observation[:recovered]
        }
      )
    end
    countries
  end

end
