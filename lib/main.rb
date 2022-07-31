require "yaml"

class Game
  def initialize()
    #stores all guessed letters.
    @guesses = [] 
    #Used for checking if the current game has been saved to exit.
    @saved = false

    #Find word through sample and readlines.
    dictionary = File.open("dictionary.txt","r")
    @word = ""
    while @word.length < 5 || @word.length > 12
      dictionary.rewind
      @word = dictionary.readlines.sample.chomp
    end
  end

  attr_reader :word
  attr_accessor :saved

  
  #Checks if the game is over
  def over?()
    return true if @guesses.length > 12
    return true if generate_display_word.gsub(" ","") == @word
    return false
  end

  #Plays a round of the game
  def play_round()
    puts ""
    puts "Current board:\n"
    puts ""
    display_progress()
    puts ""
    get_guess
  end

  

  def generate_display_word
    displayed_word = []
    @word.split("").each do |letter|
      displayed_word.push("#{letter} ") if @guesses.include?(letter)
      displayed_word.push("_ ") if !@guesses.include?(letter)
    end
    displayed_word.join
  end

  private

  def display_progress()
    displayed_word = generate_display_word
    puts displayed_word
    puts ""
    puts "You have guessed the following letter:"
    puts @guesses.to_s
    displayed_word
  end
  
  def get_guess
    puts "Guess your next letter: (or type save, to save the game)"
    guess = gets.chomp.downcase
    until (guess.length == 1 && !@guesses.include?(guess))
      if guess == "save"
        save_game()
        return
      end
      puts ""
      puts "Input error, try again. What letter do you want to guess?:"
      guess = gets.chomp.downcase
    end
    @guesses.push(guess.to_s)

  end

  #Saves the game class instance in the "saved" folder.
  def save_game
    puts "What should your save-file be called?"

    begin
      #getting all saved files to prevent overwriting.
      saved_files = Dir.glob("saved/*")
      #gets file_name from user
      file_name = "saved/#{gets.chomp.downcase}.yaml"

      #Makes sure that user wants to overwrite or choose a new file name.
      unique_file_name = false
      until unique_file_name
        if saved_files.include?(file_name)
          puts "Current file name already exists, do you want to overwrite? (Yes/no)"
          answer = gets.chomp.downcase
          until answer == "yes" || answer == "no"
            puts "wrong input. Do you want to overwrite? (Yes/no)"
            answer = gets.chomp.downcase
          end
          if answer == "yes"
            unique_file_name = true
          elsif answer == "no"
            puts "Choose another file name:"
            file_name = "saved/#{gets.chomp.downcase}.yaml"
          end
        #Ends loop
        else
          unique_file_name = true
        end
      end

      #Saves the game into the "saved" folder
      File.open(file_name,"w") do |file|
        file.write YAML.dump(self)
        puts "Saving..."
        sleep(2)
        puts "Game saved!"
      end
      @saved = true
    rescue StandardError=>e
      p e
      puts "Something went wrong. Try another save file name:"
      retry
    end
  end
end


#Start dialogue
puts "Hello, would you like to play new game (1) or load an old game(2)?"
#Gets the answer for if a game should be loaded
answer = gets.chomp
until answer == "1" || answer == "2"
  puts "Choose: \n1. Play a new game. \n 2. Load an older game."
  answer = gets.chomp
end

#used to move scope of game variable.
game = ""

#Opens save file.
if answer == "2"
  puts ""
  puts "Here are all your saved games:"
  saved_games = Dir.glob("saved/*")
  saved_games.each do |x|
    puts x.split("/")[1].split(".")[0]
  end
  puts ""
  puts "Which file would you like to load?"

  begin
    File.open("saved/#{gets.chomp.downcase}.yaml", "r") do |file|
      puts "loading..."
      sleep(2)
      puts ""
      puts "Here is your game:"
      game = YAML.load(file, permitted_classes: [Game])
    end
  rescue
    puts "The file name you wrote doesn't exist. Try again:"
    retry
  end

elsif answer == "1"
  puts "Starting a new game..."
  game = Game.new()
  sleep(0)
end

#Continues game until it was either lost or won
until game.over? || game.saved == true
  game.play_round
end


#Checks if game was lost or won
if game.saved != true
  if game.generate_display_word.include?("_")
    puts "You lost.."
    puts ""
    puts "The word was: #{game.word.capitalize}"
  else
    puts "You won!"
  end
else
  puts ""
  puts "Because the game has been saved, we are exiting the game."
end




