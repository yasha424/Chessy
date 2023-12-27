//
//  CreatePuzzleView.swift
//  Chessy
//
//  Created by yasha on 22.12.2023.
//

import SwiftUI

struct CreatePuzzleView: View {
    
    @StateObject private var vm = PuzzleViewModel(
        puzzle: Puzzle(id: UUID().uuidString, fen: "8/8/8/8/8/8/8/8 w - 0 1 KQkq", moves: [], rating: 0),
        creating: true
    )
    @Namespace private var pieceImageNamespace
    @State private var squarePositions = [Position: CGRect]()
    @State private var draggedTo: Position?
    @State private var notificationMessage: String? = nil
    @State private var blackMove = false
    @State private var selection: String? = ""
    @State private var isSuccessful = false
    @State private var rating = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            HStack {
                Text("White")

                Toggle("", isOn: $blackMove)
                    .labelsHidden()
                    .tint(.primary.opacity(0.5))

                Text("Black")
                Spacer()
                TextField("Rating", text: $rating)
                    .keyboardType(.numberPad)
                    .padding()
                    .glassView()
                
                NavigationLink(
                    destination: CreatePuzzleMovesView(vm: vm, isSuccessful: $isSuccessful),
                    tag: "A", selection: $selection) {}
            }
            .padding(16)
            .onAppear {
                if isSuccessful {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }

            notificationView
            VStack(spacing: 16) {
                blackPieces
                    .frame(height: 60)
                    .zIndex(1)
                
                VStack(spacing: 0) {
                    ForEach(0..<8) { i in
                        HStack(spacing: 0) {
                            ForEach(0..<8) { j in
                                if let position = Position(rawValue: (7 - i) * 8 + j) {
                                    GeometryReader { proxy in
                                        ZStack {
                                            if position.y == 0 {
                                                HStack {
                                                    VStack {
                                                        Text(position.rank)
                                                            .minimumScaleFactor(0.2)
                                                            .font(.system(size: 10))
                                                            .opacity(0.7)
                                                            .padding(.leading, 2)
                                                        Spacer()
                                                    }
                                                    Spacer()
                                                }
                                            }
                                            if position.x == 0 {
                                                HStack {
                                                    Spacer()
                                                    VStack {
                                                        Spacer()
                                                        Text(position.file)
                                                            .minimumScaleFactor(0.2)
                                                            .font(.system(size: 10))
                                                            .opacity(0.7)
                                                            .padding(.leading, 2)
                                                    }
                                                }
                                            }
                                            
                                            if position.x % 2 == position.y % 2 {
                                                Colors.whiteSquare.opacity(0.3)
                                            } else {
                                                Colors.blackSquare.opacity(0.3)
                                            }
                                            
                                            PieceOnBoardView(
                                                vm: vm,
                                                position: position,
                                                draggedTo: $draggedTo,
                                                squarePositions: $squarePositions,
                                                checkPointIntersection: checkPointIntersection
                                            )
                                            
                                            if draggedTo == position {
                                                Rectangle()
                                                    .stroke(lineWidth: 2)
                                            }
                                        }
                                        .aspectRatio(1, contentMode: .fit)
                                    }
                                }
                            }
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .padding()
                .glassView()
                .padding(.horizontal)
                
                whitePieces
                    .frame(height: 60)
            }
            .glassView()
            .padding(10)
            Spacer()
        }
        .onTapGesture { UIApplication.shared.endEditing() }
        .customBackground()
        .toolbar {
            Button {
                vm.setTurnColor(blackMove ? .black : .white)
                vm.setPuzzleRating(Int(rating) ?? 1200)
                withAnimation(.spring) {
                    notificationMessage = vm.checkPosition()
                }
                if notificationMessage == nil {
                    selection = "A"
                }
            } label: {
                Text("Done")
            }
        }
    }
    
    private var notificationView: some View {
        VStack {
            if let msg = notificationMessage {
                Text(msg)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red.opacity(0.3))
                    .glassView()
                    .padding()
            }
        }
    }
    
    func checkPointIntersection(_ point: CGPoint) -> Position? {
        for squarePosition in squarePositions {
            if squarePosition.value.contains(point) {
                return squarePosition.key
            }
        }
        return nil
    }

    private var whitePieces: some View {
        HStack {
            ForEach(PieceType.allCases) { pieceType in
                Spacer()
                ZStack {
                    PieceView(
                        vm: vm,
                        pieceColor: .white,
                        pieceType: pieceType,
                        draggedTo: $draggedTo,
                        checkPointIntersection: checkPointIntersection
                    )
                }
                Spacer()
            }
        }
        .padding(8)
    }
    
    private var blackPieces: some View {
        HStack {
            ForEach(PieceType.allCases) { pieceType in
                Spacer()
                ZStack {
                        PieceView(
                            vm: vm,
                            pieceColor: .black,
                            pieceType: pieceType,
                            draggedTo: $draggedTo,
                            checkPointIntersection: checkPointIntersection
                        )
                }
                Spacer()
            }
        }
        .padding(8)
    }
}

private struct PieceOnBoardView: View {
    var vm: PuzzleViewModel
    @State private var isDragged = false
    @State private var offset = CGSize.zero
    let position: Position
    @Binding var draggedTo: Position?
    @Binding var squarePositions: [Position: CGRect]
    @State private var globalPosition: CGRect = CGRect.zero
    let checkPointIntersection: (_ point: CGPoint) -> Position?
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                if let piece = vm.getPiece(atPosition: position) {
                    Image(ImageNames.color[piece.color]! + ImageNames.type[piece.type]!)
                        .resizable()
                        .scaledToFit()
                        .padding(proxy.size.width / 8)
                        .offset(offset)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    isDragged = true
                                    offset = gesture.translation
                                    let point = CGPoint(
                                        x: globalPosition.origin.x + gesture.location.x,
                                        y: globalPosition.origin.y + gesture.location.y
                                    )
                                    draggedTo = checkPointIntersection(point)
                                }
                                .onEnded { gesture in
                                    isDragged = false
                                    vm.removePiece(at: self.position)
                                    if let position = draggedTo {
                                        vm.addPiece(piece, at: position)
                                        draggedTo = nil
                                        offset = CGSize.zero
                                    } else {
                                        withAnimation(.spring) {
                                            offset = CGSize.zero
                                        }
                                    }
                                }
                        )
                }
            }
            .onAppear {
                globalPosition = proxy.frame(in: .global)
                squarePositions[position] = globalPosition
            }
        }
    }
}

private struct PieceView: View {
    var vm: PuzzleViewModel
    @State private var isDragged = false
    @State private var offset = CGSize.zero
    let pieceColor: PieceColor
    let pieceType: PieceType
    @Binding var draggedTo: Position?
    @State private var globalPosition: CGRect = CGRect.zero
    let checkPointIntersection: (_ point: CGPoint) -> Position?
    
    var body: some View {
        ZStack {
            if isDragged {
                Image(ImageNames.color[pieceColor]! + ImageNames.type[pieceType]!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.2)
            }
            GeometryReader { proxy in
                Image(ImageNames.color[pieceColor]! + ImageNames.type[pieceType]!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(x: isDragged ? 2 : 1, y: isDragged ? 2 : 1)
                    .offset(CGSize(width: offset.width, height: offset.height - (isDragged ? 50 : 0)))
                    .onAppear { globalPosition = proxy.frame(in: .global) }
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            withAnimation(.spring()) {
                                isDragged = true
                            }
                            offset = gesture.translation
                            let point = CGPoint(
                                x: globalPosition.origin.x + gesture.location.x,
                                y: globalPosition.origin.y + gesture.location.y
                            )
                            draggedTo = checkPointIntersection(point)
                        }
                        .onEnded { gesture in
                            if let position = draggedTo {
                                vm.addPiece(Piece(color: pieceColor, type: pieceType), at: position)
                                draggedTo = nil
                                offset = CGSize.zero
                            }
                            withAnimation(.spring) {
                                offset = CGSize.zero
                                isDragged = false
                            }
                        }
                    )
            }
        }
    }
}

#Preview {
    CreatePuzzleView()
}

