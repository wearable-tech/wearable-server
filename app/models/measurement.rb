class Measurement < ActiveRecord::Base
  belongs_to :user

  def oxygen_level
    if blood_oxygenation <= 30
      1
    elsif blood_oxygenation <= 50
      2
    elsif blood_oxygenation <= 80
      3
    else
      0
    end
  end

  def pulse_level
    if pulse_rate >= 160 or pulse_rate <= 30
      1
    elsif pulse_rate >= 140 or pulse_rate <= 40
      2
    elsif pulse_rate >= 120 or pulse_rate <= 60
      3
    else
      0
    end
  end  
end
