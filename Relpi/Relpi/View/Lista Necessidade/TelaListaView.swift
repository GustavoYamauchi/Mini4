//
//  TelaListaView.swift
//  Mini4
//
//  Created by Gustavo Rigor on 06/10/21.
//

import SwiftUI
import Firebase

struct TelaListaView: View {

    @ObservedObject var telaViewModel: TelaListaViewModel
    
    @State var gestureIsValid = false
    
    // MARK: Gesture
    var changePage : some Gesture{
        DragGesture()
            .onChanged { gesture in
                gestureIsValid = false
                if gesture.translation.height > 50{
                    gestureIsValid = true
                }
                
                if gesture.translation.height < -50{
                    gestureIsValid = true
                }
            }
            .onEnded({ _ in
                if gestureIsValid {
                  hideKeyboard()
                }
            })
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            HStack{
                Image("filter")
                    .renderingMode(.template)
                    .foregroundColor(telaViewModel.listaCategorizada || telaViewModel.apenasUrgente ? .primaryButton : .backgroundPrimarySearch)
                    .frame(width: 40, height: 40, alignment: .center)
                    .onTapGesture {
                        telaViewModel.mostrarFiltros = true
                    }
                
                Spacer()
                Image("collection")
                    .renderingMode(.template)
                    .foregroundColor(!telaViewModel.listaVertical ? .primaryButton : .backgroundPrimarySearch)
                    .frame(width: 40, height: 40, alignment: .center)
                    .padding(.trailing, 20)
                    .onTapGesture {
                        telaViewModel.listaVertical = false
                    }
                
                Image("table")
                    .renderingMode(.template)
                    .foregroundColor(telaViewModel.listaVertical ? .primaryButton : .backgroundPrimarySearch)
                    .frame(width: 40, height: 40, alignment: .center)
                    .onTapGesture {
                        telaViewModel.listaVertical = true
                    }
                
            }.padding(.horizontal, 30)
            .padding(.vertical, 20)
            
            Text("Lista de necessidades")
                .padding(.top, 10)
                .padding(.leading, 25)
                .foregroundColor(Color.primaryButton)
                .font(.system(size: 24, weight: .bold, design: .default))
            
            Text("\(telaViewModel.dataAtualizada).")
                .padding(.leading, 25)
                .foregroundColor(Color.gray)
                .font(.system(size: 14, weight: .regular, design: .default))
                .padding(.bottom, 10)
            
            SearchBarView(pesquisando: $telaViewModel.itemPesquisado, placeholder: "Pesquisar")
                .padding(.vertical, 20)
            
            ScrollView{
            
                #if Relpi
//                Button(action: {
//                    print("TODO: Fazer caixa de doação(?) resp: Não no mvp")
//                }, label: {
//                    Text("Adicionar itens na caixa de doação")
//                })
//                .buttonStyle(PrimaryButton())
//                .padding(.vertical, 20)
                if telaViewModel.items.count > 0 {
                    DialogCard(text: "Para realizar a doação, entre em contato com a ONG. Nossa plataforma apenas cataloga os itens demandados! :)", colorStyle: .yellow)
                        .padding(.vertical, 20)
                } else {
                    DialogCard(text: "Essa ONG ainda não precisa de nenhum item! :)", colorStyle: .yellow)
                        .padding(.vertical, 20)
                }

                #else
                Button(action: {}, label: {
                    NavigationLink(destination: FormItem(itemViewModel: .init(idOng: telaViewModel.idOng), novaTela: $telaViewModel.voltouTela), label: {
                        Text("Adicionar item")
                            .frame(minWidth: 0, maxWidth: .infinity)
                    })
                })
                .buttonStyle(PrimaryButton())
                .padding(.vertical, 20)
                #endif
                if telaViewModel.listaVertical{
                    if !telaViewModel.listaCategorizada{
                        ListaVerticalItem(telaViewModel: telaViewModel, trocaDeTela: $telaViewModel.voltouTela)
                        
                    }else{
                        VStack(alignment: .leading){
                            ForEach(telaViewModel.categorias, id: \.self){ categoria in
                                ListaVerticalItem(categoria: categoria, telaViewModel: telaViewModel, trocaDeTela: $telaViewModel.voltouTela)
                            }
                        }
                    }
                }else{
                    if !telaViewModel.listaCategorizada{
                        ListaGridItem(telaViewModel: telaViewModel)
                        
                    }else{
                        VStack(alignment: .leading){
                            ForEach(telaViewModel.categorias, id: \.self){ categoria in
                                ListaGridItem(categoria: categoria, telaViewModel: telaViewModel)
                            }
                        }
                        
                    }
                    
                }
            }
        }
        .sheet(isPresented: $telaViewModel.mostrarFiltros){
            FiltroModal(mostrarCategorias: $telaViewModel.listaCategorizada, mostrarApenasUrgentes: $telaViewModel.apenasUrgente, mostrandoView: $telaViewModel.mostrarFiltros)
        }
        .onChange(of: telaViewModel.voltouTela) { _ in
            telaViewModel.atualizar()
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .gesture(changePage)
        
    }
}

