package com.gemwallet.android.features.create_wallet.views

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.gemwallet.android.features.create_wallet.components.WordChip
import com.gemwallet.android.ui.DisableScreenShooting
import com.gemwallet.android.ui.R
import com.gemwallet.android.ui.components.buttons.MainActionButton
import com.gemwallet.android.ui.components.screen.PhraseLayout
import com.gemwallet.android.ui.components.screen.Scene
import com.gemwallet.android.ui.theme.Spacer16
import com.gemwallet.android.ui.theme.isSmallScreen
import com.gemwallet.android.ui.theme.paddingDefault
import kotlin.math.min

@OptIn(ExperimentalLayoutApi::class)
@Composable
internal fun CheckPhrase(
    words: List<String>,
    onDone: (String) -> Unit,
    onCancel: () -> Unit,
) {
    DisableScreenShooting()

    // 随机选择3个位置进行验证
    val selectedIndices = remember {
        words.indices.shuffled().take(3).sorted()
    }
    
    val selectedWords = remember {
        selectedIndices.map { words[it] }
    }

    val random = remember {
        // 创建包含所有助记词的选项，但只验证选中的3个
        val allWordsShuffled = words.mapIndexed { index, word -> Pair(index, word) }.shuffled()
        allWordsShuffled
    }
    
    val result = remember {
        mutableStateListOf<String>()
    }
    
    val isDone by remember {
        derivedStateOf {
            result.size == 3 && result.zip(selectedWords).all { (input, expected) -> input == expected }
        }
    }
    val isSmallScreen = isSmallScreen()

    val onWordClick: (String) -> Boolean = { word ->
        val index = result.size
        if (index < selectedWords.size && selectedWords[index] == word) {
            result.add(word)
            true
        } else {
            false
        }
    }

    Scene(
        title = stringResource(id = R.string.transfer_confirm),
        onClose = onCancel,
        padding = PaddingValues(horizontal = paddingDefault),
        mainAction = {
            AnimatedVisibility(
                visible = isDone || !isSmallScreen,
                enter = fadeIn(),
                exit = fadeOut(),
            ) {
                MainActionButton(
                    title = stringResource(id = R.string.common_continue),
                    enabled = isDone,
                ) {
                    onDone(words.joinToString(" "))
                }
            }
        }
    ) {
        Column(
            modifier = Modifier.verticalScroll(rememberScrollState())
        ) {
            Text(
                text = stringResource(id = R.string.secret_phrase_confirm_quick_test_title),
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.secondary,
            )
            Spacer16()
            
            // 显示需要验证的位置
            Text(
                text = stringResource(
                    id = R.string.secret_phrase_confirm_select_words,
                    selectedIndices.map { it + 1 }.joinToString(", ")
                ),
                textAlign = TextAlign.Center,
                color = MaterialTheme.colorScheme.primary,
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.fillMaxWidth()
            )
            Spacer16()
            
            // 显示当前进度
            Column {
                selectedIndices.forEachIndexed { index, position ->
                    val wordText = if (index < result.size) result[index] else ""
                    val isNext = index == result.size
                    
                    Surface(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp),
                        color = if (isNext) MaterialTheme.colorScheme.primary.copy(alpha = 0.1f) 
                               else MaterialTheme.colorScheme.surface,
                        shape = MaterialTheme.shapes.medium,
                        border = BorderStroke(
                            1.dp, 
                            if (isNext) MaterialTheme.colorScheme.primary 
                            else MaterialTheme.colorScheme.outline
                        )
                    ) {
                        Text(
                            text = "${position + 1}. $wordText",
                            modifier = Modifier.padding(16.dp),
                            style = MaterialTheme.typography.bodyLarge,
                            color = if (wordText.isNotEmpty()) MaterialTheme.colorScheme.primary 
                                   else MaterialTheme.colorScheme.onSurface
                        )
                    }
                }
            }
            
            Spacer16()
            
            // 选项按钮
            AnimatedVisibility(visible = !isDone) {
                FlowRow(
                    modifier = Modifier
                        .padding(vertical = 16.dp)
                        .fillMaxWidth(),
                    maxItemsInEachRow = 3,
                    horizontalArrangement = Arrangement.Center,
                ) {
                    random.forEach { word ->
                        WordChip(word.second, true, onWordClick)
                    }
                }
            }
        }
    }
}