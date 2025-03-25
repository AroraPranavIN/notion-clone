import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NoteViewModel()
    @State private var showingAddNote = false
    
    var body: some View{
        NavigationView{
            List {
                ForEach(viewModel.notes) { note in
                    NavigationLink(destination: NoteDetailView(note: note, viewModel: viewModel)) {
                        VStack(alignment: .leading) {
                            Text(note.title)
                                .font(.headline)
                            Text(note.content)
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .navigationTitle("NotionClone")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddNote = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(viewModel: viewModel)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider{
    static var previews: some View {
        ContentView()
    }
}
