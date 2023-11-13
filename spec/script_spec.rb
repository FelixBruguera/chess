require './script.rb'

RSpec.configure do |rspec|
    rspec.mock_with :rspec do |mocks|
        mocks.patch_marshal_to_support_partial_doubles = true
    end
end

describe Chess do
    subject(:game) {described_class.new}

    describe "#player_input" do
        it 'updates @turn' do
            allow(game).to receive(:gets).and_return('p5d')
            game.player_input
            expect(game.instance_variable_get(:@turn)).to include('Black')
        end
    end

    describe 'piece_name' do
        it 'works with pawns' do
            expect(game.piece_name('P','Black')).to eq('♟︎')
        end
        it 'works with bishops' do
            expect(game.piece_name('B','White')).to eq('♗')
        end
    end

    describe '#legal_moves' do
        context 'when given a valid move' do
            it 'works with pawns' do
                piece = game.piece_name('P','Black')
                expect(game.legal_moves(piece, '5_d', '5_b', 'White')).to eq(true)
            end
        end
        context 'when given an invalid move' do
            it 'returns false' do
                piece = game.piece_name('P','Black')
                expect(game.legal_moves(piece, '5_e', '5_b', 'White')).to eq(false)
            end
        end
    end

    describe '#path' do
        it 'returns an array including target' do
            piece = game.piece_name('P','Black')
            expect(game.path(piece, '5_b', '5_d')).to include('5_d')
        end
    end

    describe 'posible_moves' do
        context 'when given a valid position' do
            it 'returns the posible positions' do
                piece = game.piece_name('P','White')
                expect(game.posible_moves(piece, 'White', '5_d')).to eq(['5_b'])
            end
            it 'works with the queen' do
                allow(game).to receive(:gets).and_return('p4d')
                game.player_input
                piece = game.piece_name('Q','White')
                expect(game.posible_moves(piece, 'White', '4_c')).to eq(['4_a'])
            end
        end
        context 'when given an invalid position' do
            it 'returns false' do
                piece = game.piece_name('P','White')
                expect(game.posible_moves(piece, 'White', '5_e')).to eq(false)
            end
        end
    end

    describe '#update_position' do
        it 'updates @positions' do
            allow(game).to receive(:gets).and_return('p4d')
            game.player_input
            expect(game.instance_variable_get(:@positions)[:White].values.flatten).to include('4_d')
        end
    end

    describe '#remove_piece' do
        it 'removes the piece' do
            positions = game.instance_variable_get(:@positions)
            game.remove_piece('Black', '5_b', positions)
            expect(game.instance_variable_get(:@positions)[:White].values.flatten).not_to include('5_b')
        end
    end

    describe '#path_check' do
        context 'when the path is valid' do
            it 'returns good' do
                piece = game.piece_name('P','White')
                path = game.path(piece, '5_b', '5_d')
                expect(game.path_check(path, 'White', piece)).to eq('good')
            end
            it 'works with the knight' do
                piece = game.piece_name('N','White')
                path = game.path(piece, '7_a', '6_c')
                expect(game.path_check(path, 'White', piece)).to eq('good')
            end
        end
        context 'when the path is invalid' do
            it 'returns good' do
                piece = game.piece_name('Q','White')
                path = game.path(piece, '5_a', '5_d')
                expect(game.path_check(path, 'White', piece)).to eq(false)
            end
        end
        context 'when capturing' do
            it 'returns true' do
                allow(game).to receive(:gets).and_return('p4d')
                game.player_input
                allow(game).to receive(:gets).and_return('p3e')
                game.player_input
                piece = game.piece_name('P','White')
                path = game.path(piece, '4_d', '3_e')
                expect(game.path_check(path, 'White', piece, true)).to eq(true)
            end
            it 'removes the piece captured' do
                allow(game).to receive(:gets).and_return('p4d')
                game.player_input
                allow(game).to receive(:gets).and_return('p3e')
                game.player_input
                piece = game.piece_name('P','White')
                path = game.path(piece, '4_d', '3_e')
                game.path_check(path, 'White', piece, true)
                expect(game.instance_variable_get(:@positions)[:Black].values.flatten).not_to include('3_e')
            end
        end
    end

    describe '#check_pieces' do
        context 'when the game is in check' do
            it 'returns the path to checkmate' do
                targets = ['6_c', '5_e', '7_d', '8_d']
                pieces = [game.piece_name('P','White'), game.piece_name('P','Black'), game.piece_name('P','White'), game.piece_name('Q','Black')]
                players = ['White', 'Black', 'White', 'Black']
                positions = ['6_b', '5_g', '7_b', '4_h']
                (0..3).each {|index| game.update_position(pieces[index], players[index], positions[index], targets[index])}
                expect(game.check_pieces('Black')).to include('8_d')
            end
        end
        context 'when the game is not in check' do
            it 'returns false' do
            expect(game.check_pieces('Black')).to eq(false)
            end
        end
    end
    
    describe '#king_moves' do
        context 'when the king doesnt have moves' do
            it 'returns false' do
                expect(game.king_moves(:White)).to eq(false)
            end
        end
        context 'when the king has moves' do
            it 'returns true' do
                game
                allow(game).to receive(:gets).and_return('p5c')
                game.player_input
                expect(game.king_moves(:Black)).to eq(true)
            end
        end
    end

    describe '#checkmate' do
        context 'when there is a checkmate' do
            it 'updates @checkmate' do
                moves = ['p6c', 'p5e', 'p7d', 'q8d']
                moves.each do |move| 
                    allow(game).to receive(:gets).and_return(move)
                    game.player_input
                end
                path = game.check_pieces('Black')
                game.checkmate(path, 'Black', true, true)
                expect(game.instance_variable_get(:@checkmate)).to eq(true)
            end
        end
        context 'when there isnt a checkmate' do
            it 'returns false' do
                path = game.check_pieces('Black')
                expect(game.checkmate(path, 'Black', true, true)).to eq(false)
            end
        end
        it 'works with Fools Mate' do
            moves = ['p6c', 'p5e', 'p7d', 'q8d']
            moves.each do |move| 
                allow(game).to receive(:gets).and_return(move)
                game.player_input
            end
            path = game.check_pieces('Black')
            game.checkmate(path, 'Black', true, true)
            expect(game.instance_variable_get(:@checkmate)).to eq(true)
        end
        it 'works with Dutch defense Mate' do
            moves = ['p4d', 'p6e', 'b7e', 'p8f','b8d','p7e','p5d','p8d','q8e']
            moves.each do |move| 
                allow(game).to receive(:gets).and_return(move)
                game.player_input
            end
            path = game.check_pieces('White')
            game.checkmate(path, 'White', true, true)
            expect(game.instance_variable_get(:@checkmate)).to eq(true)
        end

        it 'works with Scholars Mate' do
            moves = ['p5d', 'p5e', 'b3d', 'p4f','q6c','n3f','q6g']
            moves.each do |move| 
                allow(game).to receive(:gets).and_return(move)
                game.player_input
            end
            path = game.check_pieces('White')
            game.checkmate(path, 'White', true, true)
            expect(game.instance_variable_get(:@checkmate)).to eq(true)
        end
    end

    #describe '#load_game' do
    #    it 'loads the saved game file' do
    #        allow(game).to receive(:gets).and_return('load', '0')
    #        game.player_input
    #        expect(game.instance_variable_get(:@positions)[:White].values.flatten).to include('4_c')
    #        expect(game.instance_variable_get(:@positions)[:Black].values.flatten).to include('6_f')
    #    end
    #end

end