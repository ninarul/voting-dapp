import 'package:flutter/material.dart';
import 'package:flutter_dapp/services/functions.dart';
import 'package:web3dart/web3dart.dart';

class ElectionInfo extends StatefulWidget {
  final Web3Client ethClient;
  final String electionName;
  const ElectionInfo({
    Key? key,
    required this.ethClient,
    required this.electionName,
  }) : super(key: key);

  @override
  _ElectionInfoState createState() => _ElectionInfoState();
}

class _ElectionInfoState extends State<ElectionInfo> {
  TextEditingController addCandidateController = TextEditingController();
  TextEditingController authorizeVoterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.electionName)),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFutureData(
                    future: getCandidatesNum(widget.ethClient),
                    label: 'Total Candidates',
                  ),
                  _buildFutureData(
                    future: getTotalVotes(widget.ethClient),
                    label: 'Total Votes',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInputRow(
                controller: addCandidateController,
                hintText: 'Enter Candidate Name',
                buttonText: 'Add Candidate',
                onPressed: () {
                  if (addCandidateController.text.isNotEmpty) {
                    addCandidate(addCandidateController.text, widget.ethClient);
                  } else {
                    _showError('Please enter a candidate name.');
                  }
                },
              ),
              _buildInputRow(
                controller: authorizeVoterController,
                hintText: 'Enter Voter Address',
                buttonText: 'Add Voter',
                onPressed: () {
                  if (authorizeVoterController.text.isNotEmpty) {
                    authorizeVoter(
                        authorizeVoterController.text, widget.ethClient);
                  } else {
                    _showError('Please enter a voter address.');
                  }
                },
              ),
              const Divider(),
              FutureBuilder<List>(
                future: getCandidatesNum(widget.ethClient),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final numCandidates = snapshot.data![0].toInt();
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: numCandidates,
                      itemBuilder: (context, i) {
                        return FutureBuilder<List>(
                          future: candidateInfo(i, widget.ethClient),
                          builder: (context, candidatesnapshot) {
                            if (candidatesnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (candidatesnapshot.hasError) {
                              return Text(
                                  'Error: ${candidatesnapshot.error}');
                            } else {
                              final candidate = candidatesnapshot.data![0];
                              return ListTile(
                                title: Text('Name: ${candidate[0]}'),
                                subtitle: Text('Votes: ${candidate[1]}'),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    vote(i, widget.ethClient);
                                  },
                                  child: const Text('Vote'),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFutureData(
      {required Future<List> future, required String label}) {
    return Column(
      children: [
        FutureBuilder<List>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error');
            } else {
              return Text(
                snapshot.data![0].toString(),
                style: const TextStyle(
                    fontSize: 50, fontWeight: FontWeight.bold),
              );
            }
          },
        ),
        Text(label),
      ],
    );
  }

  Widget _buildInputRow({
    required TextEditingController controller,
    required String hintText,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hintText),
          ),
        ),
        ElevatedButton(onPressed: onPressed, child: Text(buttonText)),
      ],
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
