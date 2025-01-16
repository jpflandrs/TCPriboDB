"""
Module_moteur_server.jl Un module pour serveur TCP de riboDB

Copyright or © or Copr. UCBL Lyon, France;  
contributor : [Jean-Pierre Flandrois] ([2024/12/20])
[JP.flandrois@univ-lyon1.fr]

This software is a computer program whose purpose is to create a TCP server interface to the riboDB sequence database.

This software is governed by the [CeCILL|CeCILL-B|CeCILL-C] license under French law and
abiding by the rules of distribution of free software.  You can  use, 
modify and/ or redistribute the software under the terms of the [CeCILL|CeCILL-B|CeCILL-C]
license as circulated by CEA, CNRS and INRIA at the following URL
"http://www.cecill.info". 

As a counterpart to the access to the source code and  rights to copy,
modify and redistribute granted by the license, users are provided only
with a limited warranty  and the software's author,  the holder of the
economic rights,  and the successive licensors  have only  limited
liability. 

In this respect, the user's attention is drawn to the risks associated
with loading,  using,  modifying and/or developing or reproducing the
software by the user in light of its specific status of free software,
that may mean  that it is complicated to manipulate,  and  that  also
therefore means  that it is reserved for developers  and  experienced
professionals having in-depth computer knowledge. Users are therefore
encouraged to load and test the software's suitability as regards their
requirements in conditions enabling the security of their systems and/or 
data to be ensured and,  more generally, to use and operate it in the 
same conditions as regards security. 

The fact that you are presently reading this means that you have had
knowledge of the [CeCILL|CeCILL-B|CeCILL-C] license and that you accept its terms.

"""

module Module_moteur_serveur



include("Module_fonctions_recherche.jl")
include("Module_ancilla.jl")

using .Module_fonctions_recherche, .Module_ancilla

export approx_cherche, extraitparbatchfamilles, extraitunefamille, init_werkstatt


function approx_cherche(montrieur::Function,rayon::Dict{String,String},motpartiel::Vector{String},qualitet::Vector{String}=[])#approx_cherche(montrieur,encyclo[famille][rayon],motpartiel,qualitet)
    vecteurfasta::Vector{String}=[]
    # contrôles  println(rayon)
    for i in keys(rayon) #rayon de famille
       if montrieur(motpartiel,qualitet,i) #occursin(motpartiel[1],irayon) && (occursin(vecteurqualité[1],irayon))
            # println("gardé ",i,"  /n")
            push!(vecteurfasta,rayon[i])
            # push!(vecteurfasta,join([i,rayon[i]],"\n")) #version avec nom tout complet y compris ~!!qualité... .=
            
        end
    end
    return (string(length(vecteurfasta)),join(vecteurfasta,"\n"))
end


function extraitunefamille(encyclo::Dict{String,Dict{String,Dict{String,String}}},listefamilles::Vector{String},motpartiels::Vector{String},qualitet::Vector{String},greatdirout::String,sauver::Bool)
    montrieur::Function=abinitiowhichresearch(motpartiels,qualitet)
    
    # contrôles  println(greatdirout,"  initial")
    message::Vector{String}=[]
    for famille in listefamilles #ici une seule 
        if sauver
            subgreatdirout::String=faitclasseurfamille(greatdirout,famille)
        end
        # contrôles  println(subgreatdirout,"  créé")
        push!(message,famille)
        for rayon in sort(collect(keys(encyclo[famille])),rev=true) # 16SrDNA => 16SrDNA_nuc.ser, p1p2 => _nuc_multiples.ser ... p1p2_prot_multiples.ser ...p1p2_nuc_uniques.ser ... p1p2_prot_uniques.ser
            # ici renversé pour avoir l'ordre prot-nuc et unique-multiple
            # mais même sans intérêt pour le 16/23/(S on garde
            if sauver
                fichiersorties::String=identifiepositionfichier(greatdirout,famille,rayon*".fasta") #public/atelier...atelierXXX/p1p2/p1p2_prot_multiples.ser
            end
            # contrôles println(fichiersorties)
            # push!(metaglanage,approx_cherche(encyclo[famille][rayon],motpartiel)) #renvoie une string de tout
            # contrôles println("49 ",approx_cherche(montrieur,encyclo[famille][rayon],motpartiels,qualitet)[1])
            messageetfichiers=approx_cherche(montrieur,encyclo[famille][rayon],motpartiels,qualitet)
            if occursin("_nuc",rayon) #on fait sur les nuc comme ça on a les 16S etc. aussi
                push!(message,messageetfichiers[1])
            end
            if sauver
                sauveflattoflat(messageetfichiers[2],fichiersorties) #join final
            end
        end
        #println(message)#["ul30", "77771", "198"]

        if length(message)==3 && sauver
            if message[2] == "0" && message[3] == "0"
                rm(subgreatdirout, recursive=true)
            end
        end
    end
    return join(message,";") #dans ce cas on renvoie un à la fois
end

end