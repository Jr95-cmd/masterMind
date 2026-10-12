class Players
  attr_accessor :player_role, :player_points, :player_pegs, :n_guess, :n_hints

  def initialize(pl_role, pl_points, pl_pegs, guesses, hints)
    @player_role = pl_role
    @player_points = pl_points
    @player_pegs = pl_pegs
    @n_guess = guesses
    @n_hints = hints
  end

  def self.guess_code(_player, code_guess, grid, guess)
    breaker_move = guess
    maker_move = code_guess
    player_grid = grid
    blk_guesses = []
    blk_check = maker_move.each_with_index.select { |val, indx| val == breaker_move[indx] }.map(&:last)
    blk_guesses = maker_move.each_with_index.select { |val, indx| val == breaker_move[indx] }.map(&:first)
    if $confirmed_good_guess.length < 4
      blk_guesses.each {|element| $confirmed_good_guess.append(element)}
    end
    blk_check.each { |element| player_grid[element] = "black" }
    wt_check = breaker_move.each_with_index.select do |val, indx|
      (maker_move[indx] != breaker_move[indx]) && maker_move.include?(val)
    end.map(&:last)
    
    wt_check.each_with_index do |val, _indx|
        if blk_guesses.count(breaker_move[val]) < maker_move.count(breaker_move[val])
          player_grid[val] = "white"
        end
    end
    grid.replace(player_grid).compact!
    puts "Hints are #{grid.join(" ")}"
  end

  def self.update_guesses(cur_player, grid, turn_number, cpu_guess)
    grid_to_change = grid.clone
    cur_player.n_guess["turn#{turn_number}"] = [turn_number, cpu_guess, grid_to_change]
  end

  def self.player_move_chk(cur_player)
    cur_player.n_guess.length
  end

  def self.compare_moves(cur_player, turn_number, cpu_guess, rm_guess,user)
    g_num = turn_number
    comp_arr = cur_player.n_guess
    turn_id = turn_number.to_s
    turn_hash_to_array = comp_arr.values
    guess_hint = turn_hash_to_array[g_num][2]
    guess_move = turn_hash_to_array[g_num][1]
    b_guess_count = guess_hint.count("black")
    if turn_id=='11' && b_guess_count!=4
      puts "#{user.user} loses!"
      exit
    end
    if guess_hint.count("no hint")==4
      uniq_mv=[]
      guess_move.each do |element|
        uniq_mv.append(element)
      end
      uniq_mv.uniq!
      uniq_mv.each { |val| rm_guess.append(val) }
    end
    if b_guess_count == 4
      $wn_guess = cpu_guess
      puts "winning guess is #{$wn_guess.join(" ")}, #{user.user} wins!"
      exit
    end
    g_num < 1 ? rm_guess.clear : false
      rm_guess.each do |element|
        rm_guess.append(element) if rm_guess.include?(element) == false
      end
  end
end
def array_interesect(a1, a2)
  a1.any? { |element| a2.include?(element) }
end

def conv_hash(cur_player)
  comp_arr = cur_player.n_guess
  comp_hash = comp_arr.values
end

class Game
  attr_accessor :game_round, :game_winner, :user

  def initialize(round, winner, user)
    @game_round = round
    @game_winner = winner
    @user = user
  end
end
players_selection=[]
turn_count = 12
i = 0
$wn_guess = []
rm_guess = []
cpu_guess = []
$confirmed_good_guess = []
duplicate_mv=false
PEG_SELECTION = %w[green black blue yellow red]
rsp_grid = ["no hint", "no hint", "no hint", "no hint"]
puts "Enter your role (code breaker or code maker)"
role_selection = gets.chomp
role_selection.downcase
case role_selection
when "code maker"
  player1 = Players.new(role_selection, 0, [], {}, 0)
  puts "Choose four pegs from this list as your guess code (#{PEG_SELECTION.join(',')})"
  selected_code = gets.chomp
  #if validation to ensure only peg options are used
  if selected_code.split(" ").any?{|element| !PEG_SELECTION.join(',').include?(element)} || selected_code.split(" ").length!=4
    puts "INVALID OPTION, only use the specific pegs and the number of allowed given to you with a space between each."
    exit
  else
  player1.player_pegs.replace(selected_code.split(" "))
  player2 = Players.new("code breaker", 0, [], {}, 0)
  user=Game.new(0,"","CPU")
  end
else
  puts "INVALID INPUT!, you must select one of the given options with the specified name formart."
  exit
end

pl_tcount = Players.player_move_chk(player2)

$random_selec = []
t = 0
while turn_count > 0
  
  puts"turn #{t+1}"
  if t<=5 
    cpu_guess = Array.new(4,PEG_SELECTION[t])
    player2.player_pegs = cpu_guess
  end
  pl_tcount = Players.player_move_chk(player2)

  $wn_guess.length == 0 ? cpu_guess : break
  if $confirmed_good_guess.length == 4 && duplicate_mv == false
    cpu_guess=$confirmed_good_guess.shuffle
    all_moves=conv_hash(player2)
    played_moves= all_moves
     
    players_selection = played_moves.map do |rows|
      rows[1]
    end
  end 
    if players_selection.include?(cpu_guess) 
      duplicate_mv=true 
      loop do 
        cpu_guess.shuffle!
        if !players_selection.include?(cpu_guess)
          duplicate_mv=false
          break
        end
      end
    else
      cpu_guess
  end
  if array_interesect(rm_guess, cpu_guess) == false
    puts "cpu move is #{cpu_guess.join(" ")}"
    Players.guess_code(player2, player1.player_pegs, rsp_grid, cpu_guess)
    Players.update_guesses(player2, rsp_grid, pl_tcount, cpu_guess)
    rsp_grid = ["no hint", "no hint", "no hint", "no hint"]
    Players.compare_moves(player2, i, cpu_guess, rm_guess,user)
    t += 1
  end
  i += 1
  turn_count -= 1
end
