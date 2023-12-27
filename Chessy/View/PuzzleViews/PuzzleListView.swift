//
//  PuzzleListView.swift
//  Chessy
//
//  Created by Yasha Serhiienko on 01.08.2023.
//

import SwiftUI

struct PuzzleListView: View {
    enum SortOption {
        case none, rating
    }
    enum FilterOption {
        case rating(min: Int, max: Int)
    }

    @State private var puzzleVMs = [PuzzleViewModel]()
    @State private var selectedPuzzleId: String?
    @State private var puzzleIndex = 1
    @State private var sortOption: SortOption = .none
    private var sortedPuzzleVMs: [PuzzleViewModel] {
        switch sortOption {
        case .none:
            return puzzleVMs
        case .rating:
            return puzzleVMs.sorted(by: { $0.puzzle.rating > $1.puzzle.rating })
        }
    }
    @State private var isFilterSheetPresented = false
    @StateObject var slider = CustomSlider(start: 0, end: 3000)
    @State var filterOptions: FilterOption = .rating(min: 0, max: 3000)
    @EnvironmentObject private var userObject: UserObject
    @State private var createPuzzleSheetPresented = false

    private var filteredPuzzleVMs: [PuzzleViewModel] {
        switch filterOptions {
        case .rating(let min, let max):
            return sortedPuzzleVMs.filter({ $0.puzzle.rating >= min && $0.puzzle.rating <= max })
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "arrow.up.arrow.down")
                        Picker("Sort by", selection: $sortOption) {
                            Text("None").tag(SortOption.none)
                            Text("Rating").tag(SortOption.rating)
                        }
                    }
                    Spacer()
                    Button {
                        isFilterSheetPresented.toggle()
                    } label: {
                        Label {
                            Text("Filter")
                        } icon: {
                            Image(systemName: "slider.horizontal.below.square.filled.and.square")
                        }
                    }
                    if userObject.user != nil {
                        Button {
                            createPuzzleSheetPresented = true
                        } label: {
                            Image(systemName: "plus")
                        }

                    }
                }
                .padding(.horizontal)
                
                NavigationLink {
                    CreatePuzzleView()
                } label: {
                    Text("Create puzzle")
                }


                List(selection: $selectedPuzzleId) {
                    ForEach(filteredPuzzleVMs, id: \.puzzle.id) { vm in
                        let puzzleView = PuzzleView(puzzleVM: vm)
                        ZStack {
                            NavigationLink {
                                puzzleView
                                    .onDisappear {
                                        selectedPuzzleId = nil
                                    }
                            } label: {
                                EmptyView()
                            }
                            PuzzleListViewItem(puzzleVM: vm)
                        }
                        .listRowBackground(
                            Color.gray
                                .cornerRadius(14)
                                .opacity(selectedPuzzleId == vm.puzzle.id ? 0.2 : 0)
                        )
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .swipeActions(allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                puzzleVMs.removeAll(where: { $0.puzzle.id == vm.puzzle.id })
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical)
                    }
                    .onMove { from, to in
                        puzzleVMs.move(fromOffsets: from, toOffset: to)
                    }
                    Color.clear
                        .listRowBackground(Color.clear)
                        .task {
                            let newPuzzles = await PuzzleDataSource.instance.getPuzzles(userObject.user?.email)
                            puzzleIndex += 10
                            puzzleVMs.append(contentsOf: newPuzzles.map {
                                PuzzleViewModel(puzzle: $0)
                            })
                        }
                }
            }
            .hideBackground()
            .customBackground()
            .navigationTitle("Puzzles")
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        filterOptions = .rating(
                            min: slider.lowHandle.currentValue,
                            max: slider.highHandle.currentValue
                        )
                        isFilterSheetPresented.toggle()
                    } label: {
                        Text("Done")
                    }
                }
                Spacer()
                HStack {
                    Text(String(slider.lowHandle.currentValue))
                    Spacer()
                    Text(String(slider.highHandle.currentValue))
                }
                RangeSliderView(slider: slider)
                Spacer()
            }
        }
        .refreshable {
            let newPuzzles = await PuzzleDataSource.instance.getPuzzles(userObject.user?.email)
            puzzleIndex += 10
            puzzleVMs.insert(contentsOf: newPuzzles.map { PuzzleViewModel(puzzle: $0) }, at: 0)
        }
    }
}

extension View {
    func hideBackground() -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(.hidden)
        } else {
            return self
        }
    }
}

struct PuzzleListViewPreview: PreviewProvider {
    static var previews: some View {
        PuzzleListView()
    }
}
