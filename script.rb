class Chess

  attr_accessor :board, :files, :pieces, :positions, :check
 
  def initialize
    @checkmate = false
    @board = []
    for ver in 'a'..'h'
      for hor in 1..8
        @board.push("#{hor}_#{ver}")
      end
    end
    @positions = {'Black':{'♟︎': ['1_g','2_g','3_g','4_g','5_g','6_g','7_g','8_g'], '♝': ['3_h','6_h'], '♞': ['2_h','7_h'], 
                          '♜': ['1_h', '8_h'], '♛': '4_h','♚': '5_h'},
                  'White':{'♙': ['1_b','2_b','3_b','4_b','5_b','6_b','7_b','8_b'], '♗': ['3_a','6_a'], '♘': ['2_a','7_a'], 
                            '♖': ['1_a', '8_a'], '♕': '4_a', '♔': '5_a'}}
    @pieces = ['rook', 'bishop', 'queen', 'knight','pawn', 'king']
    @files = ['h','g','f','e','d','c','b','a']
    @turn = ['White']
  end

  def legal_moves(piece, target, position, player)
    return false if position == target
    target_ver = @files.index(split_position(target)[1])
    target_hor = split_position(target)[0].to_i
    position_ver = @files.index(split_position(position)[1])
    position_hor = split_position(position)[0].to_i
    distance_ver = target_ver - position_ver
    distance_hor = target_hor - position_hor
    case piece
    when '♜', '♖'
      return true if position_hor == target_hor
      return true if position_ver == target_ver
      false
    when '♝', '♗'
      return false if position_hor == target_hor
      return false if position_ver == target_ver
      return true if distance_ver.abs == distance_hor.abs 
    when '♛', '♕'
      return true if position_hor == target_hor
      return true if position_ver == target_ver
      return true if distance_hor.abs == distance_ver.abs
      false
    when '♞', '♘'
      return true if distance_ver == 2 && (distance_hor == 1 || distance_hor == -1)
      return true if distance_ver == -2 && (distance_hor == 1 || distance_hor == -1)
      return true if distance_hor == 2  && (distance_ver == 1 || distance_ver == -1)
      return true if distance_hor == -2  && (distance_ver == 1 || distance_ver == -1)
      false
    when '♟︎', '♙'
    player == 'Black' ? opponent = :White : opponent = :Black
    opponent = @positions[opponent].values.flatten
    unless opponent.include?(target)
        return true if distance_hor.zero? && distance_ver == 1 && player == 'Black'
        return true if distance_hor.zero? && distance_ver == -1 && player == 'White'
        if ['g','b'].include?(position.split('_')[1])
          return true if distance_hor.zero? && distance_ver == 2 && player == 'Black'
            return true if distance_hor.zero? && distance_ver == -2 && player == 'White'
        end
    end
    if distance_ver == 1 && distance_hor.abs == distance_ver.abs && player == 'Black'
      return true if opponent.include?(target)
    elsif distance_ver == -1 && distance_hor.abs == distance_ver.abs && player == 'White'
      return true if opponent.include?(target)
    end
    false
    when '♚', '♔'
      return true if distance_hor == 1 && distance_ver.zero?
      return true if distance_ver == 1 && distance_hor.zero?
      return true if distance_hor == -1 && distance_ver.zero?
      return true if distance_ver == -1 && distance_hor.zero?
      return true if distance_hor.abs == 1 && distance_ver.abs == 1
      false
    end
  end

  def piece_name(piece, player)
    case piece
    when 'P'
      return '♟︎' if player == 'Black'
      '♙'
    when 'N'
      return '♞' if player == 'Black'
      '♘'
    when 'B'
      return '♝' if player == 'Black'
      '♗'
    when 'R'
      return '♜' if player == 'Black'
      '♖'
    when 'Q'
      return '♛' if player == 'Black'
      '♕'
    when 'K'
      return '♚' if player == 'Black'
      '♔'
    end
  end

  def path(piece, position, target)
    col = (position.split('_')[0].to_i)-1
    row = (@files.index(position.split('_')[1]))-1
    target_ver = @files.index(split_position(target)[1])
    target_hor = split_position(target)[0].to_i
    position_ver = @files.index(split_position(position)[1])
    position_hor = split_position(position)[0].to_i
    distance_ver = target_ver - position_ver
    distance_hor = target_hor - position_hor
    path_arr = []
    until path_arr.include?(target)
      if distance_ver.zero? && distance_hor.positive?
        path_arr.push("#{col+2}_#{@files[row+1]}")
        col += 1
      elsif distance_ver.zero? && distance_hor.negative?
        path_arr.push("#{col}_#{@files[row+1]}")
        col -= 1
      elsif distance_ver.positive? && distance_hor.zero?
        path_arr.push("#{col+1}_#{@files[row+2]}")
        row += 1
      elsif distance_ver.negative? && distance_hor.zero?
        path_arr.push("#{col+1}_#{@files[row]}")
        row -= 1
      elsif distance_ver.abs == distance_hor.abs
        if distance_ver == distance_hor && distance_ver.positive?
          path_arr.push("#{col+2}_#{@files[row+2]}")
          row += 1
          col += 1
        elsif distance_ver == distance_hor && distance_ver.negative?
          path_arr.push("#{col}_#{@files[row]}")
          row -= 1
          col -= 1
        elsif distance_ver.positive? && distance_hor.negative?
          path_arr.push("#{col}_#{@files[row+2]}")
          row += 1
          col -= 1
        else
          path_arr.push("#{col+2}_#{@files[row]}")
          row -= 1
          col += 1
        end
      else
        if distance_ver == 2
          path_arr.push("#{col+1}_#{@files[row+2]}")
          path_arr.push("#{col+1}_#{@files[row+3]}")
          if distance_hor.positive?
            path_arr.push("#{col+2}_#{@files[row+3]}")
          else
            path_arr.push("#{col}_#{@files[row+3]}")
          end
        elsif distance_ver == -2
          path_arr.push("#{col+1}_#{@files[row]}")
          path_arr.push("#{col+1}_#{@files[row-1]}")
          if distance_hor.positive?
            path_arr.push("#{col+2}_#{@files[row-1]}")
          else
            path_arr.push("#{col}_#{@files[row-1]}")
          end
        elsif distance_hor == 2
          path_arr.push("#{col+2}_#{@files[row+1]}")
          path_arr.push("#{col+3}_#{@files[row+1]}")
          if distance_ver.positive?
            path_arr.push("#{col+3}_#{@files[row+2]}")
          else
            path_arr.push("#{col+3}_#{@files[row]}")
          end
        elsif distance_hor == -2
          path_arr.push("#{col}_#{@files[row+1]}")
          path_arr.push("#{col-1}_#{@files[row+1]}")
          if distance_ver.positive?
            path_arr.push("#{col-1}_#{@files[row+2]}")
          else
            path_arr.push("#{col-1}_#{@files[row]}")
          end
        end
      end
    end
    path_arr
  end
  
  def split_position(pos)
    pos.split('_')
  end

  def draw_plays
    @drawn_board = @board.dup
    @board.each_with_index do |elem, index|
      @positions.each_key do |key|
        @positions[key].values.each_with_index do | arr, ind|
          @drawn_board[index] = positions[key].keys[ind].to_s if arr.include?(elem)
        end
      end
    end
  end

  def adjust_margin(arr)
    adjusted = []
    arr.each do |char|
      if @positions[:Black].keys.include?(char.to_sym) || @positions[:White].keys.include?(char.to_sym)
        adjusted.push("#{char} ")
      else
        char = char.split('_')
        adjusted.push(char.join(''))
      end
    end
    adjusted
  end

  def draw_board
    @drawn_board.each_slice(8) { |line| puts adjust_margin(line).join('  -  ')}
  end

  def posible_moves(piece, player, target)
    pieces = @positions.dig(player.to_sym, piece.to_sym)
    pieces_checked = []
    if pieces.instance_of?(Array)
      pieces = pieces.filter { |pos| legal_moves(piece, target, pos, player)}
      pieces.each do |pos|
        path = path(piece, pos, target)
        check = path_check(path, player, piece)
        pieces_checked.push(pos) unless check == false
      end
    else
      legal = legal_moves(piece, target, pieces, player)
      if legal == true
        path = path(piece, pieces, target)
        path_check = path_check(path, player, piece)
      end
    end
    return [pieces] if path_check == 'good'
    return false if pieces_checked.empty?
    return false if path_check == false
    pieces_checked
  end

  def pawn_promotion
    white_pawns = @positions[:White][:♙]
    black_pawns = @positions[:Black][:♟︎]
    white = white_pawns.filter { |pos| pos.split('_')[1] == 'h'}
    black = black_pawns.filter { |pos| pos.split('_')[1] == 'a'}
    return if white.empty? && black.empty?
    unless white.empty?
      remove_piece('Black', white[0], @positions)
      queen = @positions[:White][:♕]
      if queen.instance_of?(Array)
        @queen.push(white[0])
      else
        @positions[:White][:♕] = [@positions[:White][:♕]]
        @positions[:White][:♕].push(white[0])
      end
    end
    unless black.empty?
      remove_piece('White', black[0], @positions)
      queen = @positions[:Black][:♛]
      if queen.instance_of?(Array)
        queen.push(black[0])
      else
        @positions[:Black][:♛] = [@positions[:Black][:♛]]
        @positions[:Black][:♛].push(black[0])
      end
    end
  end

  def update_position(piece, player, position, target)
    old_pos = @positions[player.to_sym][piece.to_sym]
    old_pos = old_pos.index(position)
    if @positions[player.to_sym][piece.to_sym].instance_of?(Array)
      @positions[player.to_sym][piece.to_sym][old_pos] = target
    else
      @positions[player.to_sym][piece.to_sym] = target
    end
  end

  def remove_piece(player, position, all_positions)
    player == 'Black' ? opponent = :White : opponent = :Black
    piece = all_positions[opponent].select {|key, hash| hash.include?(position)}.keys[0]
    if all_positions[opponent][piece].instance_of?(Array)
      all_positions[opponent][piece].delete(position)
    else
      all_positions[opponent].delete(piece.to_sym)
    end
  end

  def path_check(path, player, piece, remove = false)
    black = @positions[:Black].values.flatten
    white = @positions[:White].values.flatten
    all_pos = black + white
    last = path[-1]
    path.pop
    unless piece == '♞' || piece == '♘'
      if path.class == Array
        path.each {|step| return false if all_pos.include?(step) }
      else
        return false if all_pos.include?(path[0])
      end
    end
    player == 'Black' ? opponent = white : opponent = black
    player == 'Black' ? player_pieces = black : player_pieces = white
    return false if player_pieces.include?(last)
    if opponent.include?(last) && remove == true
      remove_piece(player.to_s, last, @positions)
      return true
    end
    'good'
  end

  def save_game
    copy = Marshal.dump(self)
    date = Time.now.strftime('%d_%m_%y_%I_%M')
    File.open("saved_games/chess_#{date}.marshal",'w') do |f|
      f.write(copy)
    end
    puts 'Game saved'
  end

  def load_game
    files = {}
    Dir['saved_games/*'].each_with_index do |file, ind|
      files[ind] = file.to_s
    end
    files.each { |file| puts "#{file[0]} = #{file[1]}"}
    puts 'Enter the number of the game you want to load'
    user_file = gets
    user_file = user_file.chomp.to_i
    return puts 'Wrong input' unless files.keys.include?(user_file)
    game_file = Marshal.load(File.read(files[user_file]))
    game_file.opponent
  end

  def copy_game
    Marshal.load(Marshal.dump(self))
  end

  def check_pieces(player)
    player == 'Black' ? opponent = :White : opponent = :Black
    player == 'Black' ? king = :♔ : king = :♚
    player = player.to_sym
    king_pos = @positions[opponent][king]
    return true if king_pos.nil?
    pieces = @positions[player]
    check_hash = {}
    pieces.each_key do |key|
      value = posible_moves(key.to_s, player.to_s, king_pos)
      next if value == false
      check_hash[key.to_sym] = value
    end
    return false if check_hash.empty?
    path = path(check_hash.keys[0].to_s, check_hash.values[0][0].to_s, king_pos)
    path.prepend(check_hash.values[0][0])
    path.pop
    path
  end

  def king_moves(player)
    player == :Black ? opponent = :White : opponent = :Black
    player == :Black ? king = :♔ : king = :♚
    king_pos = @positions[opponent][king]
    moves = []
    @board.each do |pos|
      pmov = posible_moves(king.to_s, opponent.to_s, pos)
      next if pmov == false
      moves.push(pos) if pmov.include?(king_pos)
    end
    return false if moves.empty?
    moves.each do |pos|
      copy = copy_game
      copy.remove_piece(opponent.to_s, pos, copy.positions) if copy.positions[player].values.flatten.include?(pos)
      copy.update_position(king.to_s, opponent.to_s, king_pos, pos)
      check_pieces = copy.check_pieces(player.to_s)
      cm = copy.checkmate(check_pieces, player.to_s)
      return true if cm == false
    end
    false
  end

  def checkmate(path, player, instance_var = false, kings_turn = false, player_turn = false)
    return false if path == false
    if path == true
      @checkmate = true if instance_var == true
      return true
    end
    player == 'Black' ? opponent = :White : opponent = :Black
    player = player.to_sym
    return false if kings_turn && king_moves(player) == true
    pieces = @positions[opponent].dup
    if player_turn
      path.each do |target|
        pieces.each_key do |piece|
        next if piece == :♚ || piece == :♔
        moves = posible_moves(piece.to_s, opponent.to_s, target)
        return false if moves != false
        end
      end
    end
    @checkmate = true if instance_var == true
    true
  end

  def input_check(piece, target, player)
    moves = posible_moves(piece, player, target)
    return puts "You can't play there" unless moves
    path = path(piece, moves[0], target)
    return puts "You can't play there"  if path_check(path, player, piece, true) == false
    update_position(piece,player, moves[0], target)
    pawn_promotion
    check = check_pieces(player)
    puts "Check #{player}" if check != false
    puts "Checkmate #{player}" if checkmate(check, player, true, true, true) == true
  end

  def player_input
    player = @turn[-1]
    puts "It's #{player} turn, enter your move in algebraic notation"
    inp = gets.chomp.split('')
    return 'save' if inp.join('').upcase == 'SAVE'
    return 'load' if inp.join('').upcase == 'LOAD'
    piece = inp[0]
    target = "#{inp[1]}_#{inp[2]}"
    piece = piece_name(piece.upcase, player)
    input_check(piece, target, player)
    player == 'Black' ? @turn.push('White') : @turn.push('Black')
  end

  def computer_moves
    pieces = @positions[:Black]
    moves = []
    @board.each do | target |
      pieces.each_key do | piece |
            arr = posible_moves(piece.to_s, 'Black', target)
            moves.push([piece, arr, target]) unless arr == false
      end
    end
    moves
  end

  def computer_choice(moves)
    choice = rand(moves.length)
    choice = moves[choice]
    piece = choice[0]
    position = choice[1][0]
    target = choice[2]
    path = path(piece, position, target)
    path_check(path, 'Black', piece, true)
    update_position(piece, 'Black', position, target)
    check = check_pieces('Black')
    puts 'Check Black' if check != false
    puts 'Checkmate Black' if checkmate(check, 'Black', true, true, true) == true
  end

  def computer_input
    computer_choice(computer_moves)
    @turn.push('White')
  end

  def computer_play
    while @checkmate == false
      draw_plays
      draw_board
      input = player_input if @turn[-1] == 'White'
      computer_input if @turn[-1] == 'Black' && @checkmate == false
      return save_game if input == 'save'
      return load_game if input == 'load'
    end
  end

  def opponent
    puts 'Enter 1 to play against the computer, 2 to play against another player'
    player_choice = gets.chomp.to_i
    play if player_choice == 2
    computer_play if player_choice == 1
    puts 'Wrong input' unless [1,2].include?(player_choice)
  end

  def play
    while @checkmate == false
      draw_plays
      draw_board
      input = player_input
      return save_game if input == 'save'
      return load_game if input == 'load'
    end
  end

end

game = Chess.new
game.opponent