class Schedule
  
  def self.find_pending
    if Time.now.min == config["hourly_run_minute"]
      run_hourlies
    end
    if Time.now.strftime("%H:%M") == config["daily_run_time"]
      run_dailies
    end
    # if Time.n
  end
  
  private
    def self.run_hourlies
    end
    
    def self.run_dailies
    end

    def self.run_monthlies
    end
    
    def self.run_weeklies
    end
  
    def self.config
      YAML.load_file("#{File.dirname(__FILE__)}/../config/schedule.yml")
    end
  
end