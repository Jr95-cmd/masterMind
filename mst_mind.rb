# define classes
# two required classes players and Game
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
    # this updates the original grid value, requires a new variable instead
    breaker_move = guess
    maker_move = code_guess
    player_grid = grid
    ran_grid_num = player_grid.index("no hint")
    breaker_move.each do |e_check|
      # ran_grid_num = rand(ran_grid_num) until grid[ran_grid_num].nil?
      maker_move.each do |m_move|
        if e_check == m_move
          player_grid[ran_grid_num] = "black"
        elsif e_check != m_move && maker_move.include?(e_check) == true
          player_grid[ran_grid_num] = "white"
        end
      end
      # puts "grid is #{grid}"
    end
    grid.shuffle!
    # puts "grid is #{grid}"
  end

  def self.update_guesses(cur_player, grid, turn_number)
    cur_player.n_guess["turn#{turn_number}"]=[turn_number, cur_player.player_pegs, grid]
    #cur_player.n_guess[:"turn#{turn_number}"]=[turn_number, cur_player.player_pegs, grid] 
    puts "moves are #{cur_player.n_guess}"
  end

  def self.player_move_chk(cur_player)
    cur_player.n_guess.length
  end

  def self.compare_moves(cur_player, turn_number, _cpu_guess)
    g_num = turn_number
    prev_turn= g_num-1
    # I need to return the values in the n_guess hash based on the current turn
    # where key is equal to current turn number
    comp_arr = cur_player.n_guess
    turn_id = turn_number.to_s
    turn_id = "turn" + "#{turn_id}"
    puts "turn id is #{turn_id}"
   
    # I now need to retriev the values only of the hash

    # need to use value of specific hash key and then convert to an array
    # comp_arr1 = cur_player.n_guess[:test1]
    # puts "comp_arr1 is #{comp_arr1}"
    # comp_arr = cur_player.n_guess.map(&:to_a)
    turn_hash_to_array= comp_arr.values
     puts "guesses #{turn_hash_to_array}"
    guess_hint = turn_hash_to_array[g_num][2]
    puts "guess hint is #{guess_hint}"
    guess_move = turn_hash_to_array[g_num][1]
    o_guess_move = turn_hash_to_array[prev_turn][1]
    # if one hint peg is black in the first guess and one in the second guess, replace 1 of the original guesses with one of the new one to create a new guess
    # count number of times black appear
    o_guess_count = turn_hash_to_array[prev_turn][2].count { |element| %w[white black].include?(element) }
    puts "old guess hints = #{o_guess_count}"
    n_guess_count = guess_hint.count("white") + guess_hint.count("black")
    #compare the guess counts, if the new guess count is less than or equal to the original compare their moves
    n_guess_count <= o_guess_count ? move_dif=o_guess_move-guess_move : move_dif=nil
    puts "move difference is #{move_dif}"
    #find the moves in the original guess that are not included in the new guess
    #make the next guess move be a conbination of what was not included in the new guess



    # if when next guess is compared to code maker results to less than oguess to nguess  use other elements from the original guess to place in new guess

    # new array show not equal any elements in current guess

    puts "#{guess_move} and hint is #{guess_hint}"
  end
end

class Game
  attr_accessor :game_round, :game_winner, :cur_player

  def initialize(round, winner, cur_player)
    @game_round = round
    @game_winner = winner
    @cur_player = cur_player
  end
end
turn_count = 12
i = 0
PEG_SELECTION = %w[green black blue yellow red]
rsp_grid = ["no hint", "no hint", "no hint", "no hint"]
puts "Enter your role (code breaker or code maker)"
role_selection = gets.chomp
role_selection.downcase
case role_selection
when "code maker"
  player1 = Players.new(role_selection, 0, [], {}, 0)
  # puts player1.player_role
  puts "Chose four pegs from this list as your guess code (#{PEG_SELECTION.join(',')})"
  selected_code = gets.chomp
  player1.player_pegs.replace(selected_code.split(" "))
  player2 = Players.new("code breaker", 0, [], {}, 0)
else
  puts "INVALID INPUT!"
  # code when code breaker role is chosen first must come here
end
cpu_guess = player2.player_pegs.replace(PEG_SELECTION.sample(4))

# while statement to go here to check if code breaker guesses

Players.guess_code(player2, player1.player_pegs, rsp_grid, cpu_guess)
# I need to update the players selected guess
#code below should be updated to remove 0 and insert variable for player turn count
pl_tcount=Players.player_move_chk(player2)
Players.update_guesses(player2, rsp_grid, pl_tcount)

# if player has more than one guess call the compare method
while turn_count > 0
  pl_tcount=Players.player_move_chk(player2)
  if Players.player_move_chk(player2) > 1
    Players.compare_moves(player2, i + 1, cpu_guess)
  else
    cpu_guess = player2.player_pegs.replace(PEG_SELECTION.sample(4))
    Players.update_guesses(player2, rsp_grid, pl_tcount)
    Players.guess_code(player2, player1.player_pegs, rsp_grid, cpu_guess)
    
    #Players.compare_moves(player2, i, cpu_guess)
  end
  turn_count-= 1
end
